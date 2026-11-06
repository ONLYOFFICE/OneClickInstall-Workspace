#!/bin/bash

set -e

package_manager="yum"
package_sysname="onlyoffice";

package_services="";
DS_COMMON_NAME="onlyoffice";	
RES_APP_INSTALLED="is already installed";
RES_APP_CHECK_PORTS="uses ports"
RES_CHECK_PORTS="please, make sure that the ports are free.";
RES_INSTALL_SUCCESS="Thank you for installing ONLYOFFICE.";
RES_PROPOSAL="You can now configure your portal using the Control Panel";
RES_QUESTIONS="In case you have any questions contact us via http://support.onlyoffice.com or visit our forum at http://community.onlyoffice.com"
RES_MARIADB="To continue the installation, you need to remove MariaDB"

MAKESWAP="true"

RES_CHOICE="Please, enter Y or N"
RES_CHOICE_INSTALLATION="Continue installation [Y/N]? "

res_unsupported_version () {
	RES_UNSPPORTED_VERSION="You have an unsupported version of $DIST installed"
	RES_SELECT_INSTALLATION="Select 'N' to cancel the ONLYOFFICE installation (recommended). Select 'Y' to continue installing ONLYOFFICE"
	RES_ERROR_REMINDER="Please note, that if you continue with the installation, there may be errors"
}

res_rabbitmq_update () {
	RES_RABBITMQ_VERSION="You have an old version of RabbitMQ installed. The update will cause the RabbitMQ database to be deleted."
	RES_RABBITMQ_REMINDER="If you use the database only in the ONLYOFFICE configuration, then the update will be safe for you."
	RES_RABBITMQ_INSTALLATION="Select 'Y' to install the new version of RabbitMQ (recommended). Select 'N' to keep the current version of RabbitMQ."
}

require_value() {
	[ -n "${2-}" ] || { echo "Error: Missing value for ${1}" >&2; exit 1; }
}

while [ "$1" != "" ]; do
	case $1 in
		-h | '-?' | --help ) ;;
		-* ) require_value "$1" "$2" ;;
	esac

	case $1 in

		-ls | --localscripts )
			if [ "$2" != "" ]; then
				LOCAL_SCRIPTS=$2
				shift
			fi
		;;

		-it | --installationtype | --installation_type )
			if [ "$2" != "" ]; then
				INSTALLATION_TYPE=$(echo "$2" | awk '{print toupper($0)}');
				shift
			fi
		;;

		-gb | --gitbranch )
			if [ "$2" != "" ]; then
				GIT_BRANCH=$2
				shift
			fi
		;;

		-skiphc | --skiphardwarecheck )
			if [ "$2" != "" ]; then
				SKIP_HARDWARE_CHECK=$2
				shift
			fi
		;;

		-u | --update )
			if [ "$2" != "" ]; then
				UPDATE=$2
				shift
			fi
		;;

		-ms | --makeswap )
			if [ "$2" != "" ]; then
				MAKESWAP=$2
				shift
			fi
		;;

		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -it, --installationtype           installation type (GROUPS|WORKSPACE|WORKSPACE_ENTERPRISE)"
			echo "      -u, --update                      use to update existing components (true|false)"
			echo "      -ls, --localscripts               use 'true' to run local scripts (true|false)"
			echo "      -gb, --gitbranch                  download scripts from the given git branch (ignored with -ls true)"
			echo "      -skiphc, --skiphardwarecheck      use to skip hardware check (true|false)"
			echo "      -ms, --makeswap                   make swap file (true|false)"
			echo "      -?, -h, --help                    this help"
			echo
			exit 0
		;;

	esac
	shift
done

INSTALLATION_TYPE="${INSTALLATION_TYPE:-WORKSPACE_ENTERPRISE}"
UPDATE="${UPDATE:-false}"
LOCAL_SCRIPTS="${LOCAL_SCRIPTS:-false}"
SKIP_HARDWARE_CHECK="${SKIP_HARDWARE_CHECK:-false}"

# Reject unsupported hosts before touching the system
ARCH="$(rpm --eval '%{_arch}')"
if [ "$ARCH" != "x86_64" ]; then
	echo "ONLYOFFICE Workspace doesn't support architecture '$ARCH'"
	exit 1
fi

OS_RELEASE_ID=$(. /etc/os-release; echo "${ID}")
OS_RELEASE_MAJOR=$(. /etc/os-release; echo "${VERSION_ID%%.*}")
if [[ "${OS_RELEASE_ID}" =~ ^(centos|rhel|rocky|almalinux|ol)$ && "${OS_RELEASE_MAJOR}" =~ ^[0-9]+$ && "${OS_RELEASE_MAJOR}" -lt 9 ]]; then
	echo "Your ${OS_RELEASE_ID} ${OS_RELEASE_MAJOR} operating system has reached the end of its service life."
	echo "Please consider upgrading your operating system or using a Docker installation."
	exit 1
fi

DOWNLOAD_URL_PREFIX="https://download.onlyoffice.com/install"
[ -n "${GIT_BRANCH}" ] && DOWNLOAD_URL_PREFIX="https://raw.githubusercontent.com/ONLYOFFICE/OneClickInstall-Workspace/${GIT_BRANCH}"

source_remote_script() {
	local SCRIPT_BODY

	SCRIPT_BODY=$(curl -fsSL --retry 3 --retry-delay 2 "${DOWNLOAD_URL_PREFIX}/$1") || { echo "Error: failed to download $1" >&2; return 1; }
	bash -n <<< "${SCRIPT_BODY}" || { echo "Error: downloaded $1 is not a valid script" >&2; return 1; }
	source <(printf '%s\n' "${SCRIPT_BODY}")
}

if [ "${LOCAL_SCRIPTS}" == "true" ]; then
	source common/validate.sh
else
	source_remote_script common/validate.sh || exit 1
fi
validate_installer_arguments

cat > /etc/yum.repos.d/onlyoffice.repo <<END
[onlyoffice]
name=onlyoffice repo
baseurl=http://download.onlyoffice.com/repo/centos/main/noarch/
gpgcheck=1
gpgkey=https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE
enabled=1
END

export MYSQL_SERVER_HOST="127.0.0.1"

if [ "${LOCAL_SCRIPTS}" == "true" ]; then
	source common/hardware.sh
	source install-RedHat/tools.sh
	source install-RedHat/bootstrap.sh
	source common/check-ports.sh
	source common/swap.sh
	source install-RedHat/install-preq.sh
	source install-RedHat/install-app.sh
else
	source_remote_script common/hardware.sh || exit 1
	source_remote_script install-RedHat/tools.sh || exit 1
	source_remote_script install-RedHat/bootstrap.sh || exit 1
	source_remote_script common/check-ports.sh || exit 1
	source_remote_script common/swap.sh || exit 1
	source_remote_script install-RedHat/install-preq.sh || exit 1
	source_remote_script install-RedHat/install-app.sh || exit 1
fi
