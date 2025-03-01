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
RES_QUESTIONS="In case you have any questions contact us via http://support.onlyoffice.com or visit our forum at http://forum.onlyoffice.com"
RES_MARIADB="To continue the installation, you need to remove MariaDB"

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

while [ "$1" != "" ]; do
	case $1 in

		-ls | --localscripts )
			if [ "$2" != "" ]; then
				LOCAL_SCRIPTS=$2
				shift
			fi
		;;

		-it | --installation_type )
			if [ "$2" != "" ]; then
				INSTALLATION_TYPE=$(echo "$2" | awk '{print toupper($0)}');
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

		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -it, --installation_type          installation type (GROUPS|WORKSPACE|WORKSPACE_ENTERPRISE)"
			echo "      -u, --update                      use to update existing components (true|false)"
			echo "      -ls, --localscripts               use 'true' to run local scripts (true|false)"
			echo "      -skiphc, --skiphardwarecheck      use to skip hardware check (true|false)"
			echo "      -?, -h, --help                    this help"
			echo
			exit 0
		;;

	esac
	shift
done

if [ -z "${INSTALLATION_TYPE}" ]; then
   INSTALLATION_TYPE=${INSTALLATION_TYPE:-"WORKSPACE_ENTERPRISE"}
fi

if [ -z "${UPDATE}" ]; then
   UPDATE="false";
fi

if [ -z "${SKIP_HARDWARE_CHECK}" ]; then
   SKIP_HARDWARE_CHECK="false";
fi

cat > /etc/yum.repos.d/onlyoffice.repo <<END
[onlyoffice]
name=onlyoffice repo
baseurl=http://download.onlyoffice.com/repo/centos/main/noarch/
gpgcheck=1
gpgkey=https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE
enabled=1
END

export MYSQL_SERVER_HOST="127.0.0.1"

DOWNLOAD_URL_PREFIX="https://download.onlyoffice.com/install/install-RedHat"
if [ "${LOCAL_SCRIPTS}" == "true" ]; then
	source install-RedHat/tools.sh
	source install-RedHat/bootstrap.sh
	source install-RedHat/check-ports.sh
	source install-RedHat/install-preq.sh
	source install-RedHat/install-app.sh
else
	source <(curl ${DOWNLOAD_URL_PREFIX}/tools.sh)
	source <(curl ${DOWNLOAD_URL_PREFIX}/bootstrap.sh)
	source <(curl ${DOWNLOAD_URL_PREFIX}/check-ports.sh)
	source <(curl ${DOWNLOAD_URL_PREFIX}/install-preq.sh)
	source <(curl ${DOWNLOAD_URL_PREFIX}/install-app.sh)
fi
