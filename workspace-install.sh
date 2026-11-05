#!/bin/bash

set -e

# (c) Copyright Ascensio System Limited 2010-2026
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# You can contact Ascensio System SIA by email at sales@onlyoffice.com

PARAMETERS="";
DOCKER="";
HELP="false";
LOCAL_SCRIPTS="false";
GIT_BRANCH="";

while [ "$1" != "" ]; do
        case $1 in

	-ls | --localscripts )
	        if [ "$2" == "true" ] || [ "$2" == false ]; then
			PARAMETERS="$PARAMETERS ${1}";
			LOCAL_SCRIPTS=$2
			shift
		fi
         ;;

	-gb | --gitbranch )
	        if [ "$2" != "" ]; then
			PARAMETERS="$PARAMETERS ${1}";
			GIT_BRANCH=$2
			shift
		fi
         ;;

	 "-?" | -h | --help )
	        HELP="true"
		DOCKER="true"
		PARAMETERS="$PARAMETERS -ht workspace-install.sh";
	 ;;

	esac
	PARAMETERS="$PARAMETERS ${1}";
	shift
done

PARAMETERS="-it WORKSPACE $PARAMETERS";

root_checking () {
	if [ ! $( id -u ) -eq 0 ]; then
		echo "To perform this action you must be logged in with root rights"
		exit 1;
	fi
}

command_exists () {
	type "$1" &> /dev/null;
}

install_curl () {
	if command_exists apt-get; then
		apt-get -y update
		apt-get -y -q install curl
	elif command_exists yum; then
		yum -y install curl
	fi

	if ! command_exists curl; then
		echo "command curl not found"
		exit 1;
	fi
}

read_installation_method () {
	echo "Select 'Y' to install ONLYOFFICE using Docker (recommended). Select 'N' to install it using RPM/DEB packages.";
	echo "Please note, that in case you select RPM/DEB installation, you will need to manually install Mail Server and connect it to your ONLYOFFICE installation.";
	echo "See instructions in our Help Center: http://helpcenter.onlyoffice.com/server/docker/mail/connect-mail-server-to-community-server-via-portal-settings.aspx";
	read -p "Install with Docker [Y/N/C]? " choice
	case "$choice" in
		y|Y )
			DOCKER="true";
		;;

		n|N )
			DOCKER="false";
		;;

		c|C )
			exit 0;
		;;

		* )
			echo "Please, enter Y, N or C to cancel";
		;;
	esac

	if [ "$DOCKER" == "" ]; then
		read_installation_method;
	fi
}

root_checking

if ! command_exists curl ; then
	install_curl;
fi

if [ "$HELP" == "false" ]; then
	read_installation_method;
fi

DOWNLOAD_URL_PREFIX="http://download.onlyoffice.com/install"
[ -n "${GIT_BRANCH}" ] && DOWNLOAD_URL_PREFIX="https://raw.githubusercontent.com/ONLYOFFICE/OneClickInstall-Workspace/${GIT_BRANCH}"

run_script () {
	local script_name=$1

	if [ "${LOCAL_SCRIPTS}" == "true" ]; then
		bash "${script_name}" ${PARAMETERS}
	else
		curl -fsS -O "${DOWNLOAD_URL_PREFIX}/${script_name}" || { echo "Failed to download ${script_name}"; exit 1; }
		bash "${script_name}" ${PARAMETERS}
		rm "${script_name}"
	fi
}

if [ "$DOCKER" == "true" ]; then
	run_script install.sh
else
	if [ -f /etc/redhat-release ] ; then
		DIST=$(cat /etc/redhat-release |sed s/\ release.*//);
		REV=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//);

		REV_PARTS=(${REV//\./ });
		REV=${REV_PARTS[0]};

		if [[ "${DIST}" == CentOS* ]] && [ ${REV} -lt 7 ]; then
			echo "CentOS 7 or later is required";
			exit 1;
		fi

		run_script install-RedHat.sh
	elif [ -f /etc/debian_version ] ; then
		run_script install-Debian.sh
	else
		echo "Not supported OS";
		exit 1;
	fi
fi
