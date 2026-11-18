#!/bin/bash

set -e

package_sysname="onlyoffice";
DS_COMMON_NAME="onlyoffice";
RES_APP_INSTALLED="is already installed";
RES_APP_CHECK_PORTS="uses ports"
RES_CHECK_PORTS="please, make sure that the ports are free.";
RES_INSTALL_SUCCESS="Thank you for installing ONLYOFFICE.";
RES_PROPOSAL="You can now configure your portal using the Control Panel";
RES_QUESTIONS="In case you have any questions contact us via http://support.onlyoffice.com or visit our forum at http://community.onlyoffice.com"
MAKESWAP="true"

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

		'-?' | -h | --help )
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
ARCH="$(dpkg --print-architecture)"
if [ "$ARCH" != "amd64" ]; then
	echo "ONLYOFFICE Workspace doesn't support architecture '$ARCH'"
	exit 1
fi

OS_RELEASE_ID=$(. /etc/os-release; echo "${ID}")
OS_RELEASE_MAJOR=$(. /etc/os-release; echo "${VERSION_ID%%.*}")
# Testing/unstable Debian has no numeric release and is not checked
if [[ "${OS_RELEASE_MAJOR}" =~ ^[0-9]+$ ]] && [[ ( "${OS_RELEASE_ID}" == "ubuntu" && "${OS_RELEASE_MAJOR}" -lt 22 ) || ( "${OS_RELEASE_ID}" == "debian" && "${OS_RELEASE_MAJOR}" -lt 12 ) ]]; then
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

# Validates the arguments once, as soon as the shared script can be loaded
ARGUMENTS_VALIDATED="false"
validate_arguments_once() {
	[ "${ARGUMENTS_VALIDATED}" != "true" ] || return 0
	if [ "${LOCAL_SCRIPTS}" == "true" ]; then
		source common/validate.sh
	else
		source_remote_script common/validate.sh || exit 1
	fi
	validate_installer_arguments
	ARGUMENTS_VALIDATED="true"
}

# Without curl the shared script cannot be downloaded yet, so validation waits for its installation
if [ "${LOCAL_SCRIPTS}" == "true" ] || command -v curl >/dev/null 2>&1; then
	validate_arguments_once
fi

# Pause apt auto-updates to avoid dpkg lock contention.
APT_UNITS_TO_RESTORE=()
for APT_UNIT in apt-daily.timer apt-daily-upgrade.timer unattended-upgrades.service; do
	systemctl is-active --quiet "${APT_UNIT}" && APT_UNITS_TO_RESTORE+=("${APT_UNIT}")
done
systemctl stop apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service unattended-upgrades.service >/dev/null 2>&1 || true
finish_debian_install() {
	[ ${#APT_UNITS_TO_RESTORE[@]} -eq 0 ] || systemctl start "${APT_UNITS_TO_RESTORE[@]}" >/dev/null 2>&1 || true
}
trap finish_debian_install EXIT

if fuser /var/lib/dpkg/lock-frontend &>/dev/null; then
	echo "Waiting for /var/lib/dpkg/lock-frontend to be released (up to 60 seconds)..."
	# apt-get's DPkg::Lock::Timeout below handles slow lock release.
	timeout 60 bash -c 'while fuser /var/lib/dpkg/lock-frontend &>/dev/null; do sleep 1; done' || true
fi

# Suppress interactive apt/needrestart prompts during automated installs
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

apt-get update -y --allow-releaseinfo-change -o DPkg::Lock::Timeout=60

if [ "$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")" -eq 0 ]; then
	apt-get install -yq -o DPkg::Lock::Timeout=60 curl
fi

export MYSQL_SERVER_HOST="127.0.0.1"
validate_arguments_once

if [ "${LOCAL_SCRIPTS}" == "true" ]; then
	source install-Debian/bootstrap.sh
else
	source_remote_script install-Debian/bootstrap.sh || exit 1
fi

# add onlyoffice repo
mkdir -p -m 700 $HOME/.gnupg
echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] http://download.onlyoffice.com/repo/debian squeeze main" | tee /etc/apt/sources.list.d/onlyoffice.list
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/onlyoffice.gpg --import
chmod 644 /usr/share/keyrings/onlyoffice.gpg

declare -x LANG="en_US.UTF-8"
declare -x LANGUAGE="en_US:en"
declare -x LC_ALL="en_US.UTF-8"

if [ "${LOCAL_SCRIPTS}" == "true" ]; then
	source common/hardware.sh
	source install-Debian/tools.sh
	source common/check-ports.sh
	source common/swap.sh
	source install-Debian/install-preq.sh
	source install-Debian/install-app.sh
else
	source_remote_script common/hardware.sh || exit 1
	source_remote_script install-Debian/tools.sh || exit 1
	source_remote_script common/check-ports.sh || exit 1
	source_remote_script common/swap.sh || exit 1
	source_remote_script install-Debian/install-preq.sh || exit 1
	source_remote_script install-Debian/install-app.sh || exit 1
fi
