#!/bin/bash

# (c) Copyright Ascensio System Limited 2010-2021
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# You can contact Ascensio System SIA by email at sales@onlyoffice.com

DISK_REQUIREMENTS=40960;
MEMORY_REQUIREMENTS=8000;
CORE_REQUIREMENTS=4;

PRODUCT="onlyoffice";
BASE_DIR="/app/$PRODUCT";
NETWORK="$PRODUCT";
SWAPFILE="/${PRODUCT}_swapfile";
MACHINEKEY_PARAM=$(echo "${PRODUCT}_CORE_MACHINEKEY" | awk '{print toupper($0)}');

COMMUNITY_CONTAINER_NAME="onlyoffice-community-server";
DOCUMENT_CONTAINER_NAME="onlyoffice-document-server";
MAIL_CONTAINER_NAME="onlyoffice-mail-server";
CONTROLPANEL_CONTAINER_NAME="onlyoffice-control-panel";
ELASTICSEARCH_CONTAINER_NAME="onlyoffice-elasticsearch";
MYSQL_CONTAINER_NAME="onlyoffice-mysql-server";

COMMUNITY_IMAGE_NAME="onlyoffice/communityserver";
DOCUMENT_IMAGE_NAME="onlyoffice/documentserver-ee";
MAIL_IMAGE_NAME="onlyoffice/mailserver";
CONTROLPANEL_IMAGE_NAME="onlyoffice/controlpanel";
ELASTICSEARCH_IMAGE_NAME="onlyoffice/elasticsearch";
MYSQL_IMAGE_NAME="mysql";

COMMUNITY_VERSION="";
DOCUMENT_VERSION="";
MAIL_VERSION="";
CONTROLPANEL_VERSION="";
ELASTICSEARCH_VERSION="7.16.3";
MYSQL_VERSION="5.5";

DOCUMENT_SERVER_HOST="";

ELASTICSEARCH_PORT="9200";

MAIL_SERVER_API_HOST="";
MAIL_SERVER_DB_HOST="";
MAIL_IMAPSYNC_START_DATE="$(date +"%Y-%m-%dT%H:%M:%S")";

MAIL_DOMAIN_NAME="";

DIST="";
REV="";
KERNEL="";

UPDATE="false";

HUB="";
USERNAME="";
PASSWORD="";

INSTALL_COMMUNITY_SERVER="true";
INSTALL_DOCUMENT_SERVER="true";
INSTALL_MAIL_SERVER="true";
INSTALL_ELASTICSEARCH="true";
INSTALL_CONTROLPANEL="true";

USE_AS_EXTERNAL_SERVER="false";

PARTNER_DATA_FILE="";

INSTALLATION_TYPE="WORKSPACE_ENTERPRISE";

MAKESWAP="true";

RESTART_COMMUNITY_SERVER="false";
MOVE_COMMUNITY_SERVER_DATABASE="false";
ACTIVATE_COMMUNITY_SERVER_TRIAL="false";

MYSQL_PORT="3306";
MYSQL_DATABASE="$PRODUCT";
MYSQL_MAIL_DATABASE="${PRODUCT}_mailserver";
MYSQL_MAIL_ROOT_PASSWORD="Isadmin123";
MYSQL_MAIL_USER="mail_admin";
MYSQL_ROOT_USER="root";
MYSQL_ROOT_PASSWORD="my-secret-pw";
MYSQL_USER="${PRODUCT}_user";
MYSQL_PASSWORD="${PRODUCT}_pass";
MYSQL_HOST="";

HELP_TARGET="install.sh";

JWT_ENABLED="";
JWT_SECRET="";
CORE_MACHINEKEY="";

SKIP_HARDWARE_CHECK="false";
SKIP_VERSION_CHECK="false";
SKIP_DOMAIN_CHECK="false";

COMMUNITY_PORT=80;

while [ "$1" != "" ]; do
	case $1 in

		-ci | --communityimage )
			if [ "$2" != "" ]; then
				COMMUNITY_IMAGE_NAME=$2
				shift
			fi
		;;

		-di | --documentimage )
			if [ "$2" != "" ]; then
				DOCUMENT_IMAGE_NAME=$2
				shift
			fi
		;;

		-mi | --mailimage )
			if [ "$2" != "" ]; then
				MAIL_IMAGE_NAME=$2
				shift
			fi
		;;

		-cpi | --controlpanelimage )
			if [ "$2" != "" ]; then
				CONTROLPANEL_IMAGE_NAME=$2
				shift
			fi
		;;

		-mysqli | --mysqlimage )
			if [ "$2" != "" ]; then
				MYSQL_IMAGE_NAME=$2
				shift
			fi
		;;

		-dip | --documentserverip  )
			if [ "$2" != "" ]; then
				DOCUMENT_SERVER_HOST=$2
				shift
			fi
		;;

		-mip | --mailserverip  )
			if [ "$2" != "" ]; then
				MAIL_SERVER_API_HOST=$2
				shift
			fi
		;;

		-mdbip | --mailserverdbip  )
			if [ "$2" != "" ]; then
				MAIL_SERVER_DB_HOST=$2
				shift
			fi
		;;

		-cv | --communityversion )
			if [ "$2" != "" ]; then
				COMMUNITY_VERSION=$2
				shift
			fi
		;;

		-dv | --documentversion )
			if [ "$2" != "" ]; then
				DOCUMENT_VERSION=$2
				shift
			fi
		;;

		-mv | --mailversion )
			if [ "$2" != "" ]; then
				MAIL_VERSION=$2
				shift
			fi
		;;

		-cpv | --controlpanelversion )
			if [ "$2" != "" ]; then
				CONTROLPANEL_VERSION=$2
				shift
			fi
		;;

		-md | --maildomain )
			if [ "$2" != "" ]; then
				MAIL_DOMAIN_NAME=$2
				shift
			fi
		;;

		-u | --update )
			if [ "$2" != "" ]; then
				UPDATE=$2
				shift
			fi
		;;

		-hub | --hub )
			if [ "$2" != "" ]; then
				HUB=$2
				shift
			fi
		;;

		-un | --username )
			if [ "$2" != "" ]; then
				USERNAME=$2
				shift
			fi
		;;

		-p | --password )
			if [ "$2" != "" ]; then
				PASSWORD=$2
				shift
			fi
		;;

		-ics | --installcs | --installcommunityserver )
			if [ "$2" != "" ]; then
				INSTALL_COMMUNITY_SERVER=$2
				shift
			fi
		;;

		-ids | --installdocs | --installdocumentserver )
			if [ "$2" != "" ]; then
				INSTALL_DOCUMENT_SERVER=$2
				shift
			fi
		;;

		-ims | --installmailserver )
			if [ "$2" != "" ]; then
				INSTALL_MAIL_SERVER=$2
				shift
			fi
		;;

		-icp | --installcontrolpanel )
			if [ "$2" != "" ]; then
				INSTALL_CONTROLPANEL=$2
				shift
			fi
		;;

		-es | --useasexternalserver )
			if [ "$2" != "" ]; then
				USE_AS_EXTERNAL_SERVER=$2
				shift
			fi
		;;

		-pdf | --partnerdatafile )
			if [ "$2" != "" ]; then
				PARTNER_DATA_FILE=$2
				shift
			fi
		;;

		-it | --installationtype | --installation_type )
			if [ "$2" != "" ]; then
				INSTALLATION_TYPE=$(echo "$2" | awk '{print toupper($0)}');
				shift
			fi
		;;

		-ms | --makeswap )
			if [ "$2" != "" ]; then
				MAKESWAP=$2
				shift
			fi
		;;

		-ht | --helptarget )
			if [ "$2" != "" ]; then
				HELP_TARGET=$2
				shift
			fi
		;;

		-mysqlprt | --mysqlport )
			if [ "$2" != "" ]; then
				MYSQL_PORT=$2
				shift
			fi
		;;

		-mysqld | --mysqldatabase )
			if [ "$2" != "" ]; then
				MYSQL_DATABASE=$2
				shift
			fi
		;;

		-mysqlmd | --mysqlmaildatabase )
			if [ "$2" != "" ]; then
				MYSQL_MAIL_DATABASE=$2
				shift
			fi
		;;

		-mysqlmp | --mysqlmailpassword )
			if [ "$2" != "" ]; then
				MYSQL_MAIL_ROOT_PASSWORD=$2
				shift
			fi
		;;

		-mysqlmu | --mysqlmailuser )
			if [ "$2" != "" ]; then
				MYSQL_MAIL_USER=$2
				shift
			fi
		;;

		-mysqlru | --mysqlrootuser )
			if [ "$2" != "" ]; then
				MYSQL_ROOT_USER=$2
				shift
			fi
		;;

		-mysqlrp | --mysqlrootpassword )
			if [ "$2" != "" ]; then
				MYSQL_ROOT_PASSWORD=$2
				shift
			fi
		;;

		-mysqlu | --mysqluser )
			if [ "$2" != "" ]; then
				MYSQL_USER=$2
				shift
			fi
		;;

		-mysqlp | --mysqlpassword )
			if [ "$2" != "" ]; then
				MYSQL_PASSWORD=$2
				shift
			fi
		;;

		-mysqlh | --mysqlhost )
			if [ "$2" != "" ]; then
				MYSQL_HOST=$2
				shift
			fi
		;;

		-skiphc | --skiphardwarecheck )
			if [ "$2" != "" ]; then
				SKIP_HARDWARE_CHECK=$2
				shift
			fi
		;;

		-skipvc | --skipversioncheck )
			if [ "$2" != "" ]; then
				SKIP_VERSION_CHECK=$2
				shift
			fi
		;;

		-skipdc | --skipdomaincheck )
			if [ "$2" != "" ]; then
				SKIP_DOMAIN_CHECK=$2
				shift
			fi
		;;

		-cp | --communityport )
			if [ "$2" != "" ]; then
				COMMUNITY_PORT=$2
				shift
			fi
		;;

		-mk | --machinekey )
			if [ "$2" != "" ]; then
				CORE_MACHINEKEY=$2
				shift
			fi
		;;

		-esi | --elasticsearchimage )
			if [ "$2" != "" ]; then
				ELASTICSEARCH_IMAGE_NAME=$2
				shift
			fi
		;;

		-esv | --elasticsearchversion )
			if [ "$2" != "" ]; then
				ELASTICSEARCH_VERSION=$2
				shift
			fi
		;;

		-esh | --elasticsearchhost  )
			if [ "$2" != "" ]; then
				ELASTICSEARCH_HOST=$2
				shift
			fi
		;;

		-ies | --installelasticsearch )
			if [ "$2" != "" ]; then
				INSTALL_ELASTICSEARCH=$2
				shift
			fi
		;;

		-esp | --elasticsearchport )
			if [ "$2" != "" ]; then
				ELASTICSEARCH_PORT=$2
				shift
			fi
		;;

		-je | --jwtenabled )
			if [ "$2" != "" ]; then
				JWT_ENABLED=$2
				shift
			fi
		;;
		
		-jh | --jwtheader )
			if [ "$2" != "" ]; then
				JWT_HEADER=$2
				shift
			fi
		;;

		-js | --jwtsecret )
			if [ "$2" != "" ]; then
				JWT_SECRET=$2
				shift
			fi
		;;

		-? | -h | --help )
			echo "  Usage: bash $HELP_TARGET [PARAMETER] [[PARAMETER], ...]"
			echo
			echo "DOCKER REGISTRY AUTH:"
			echo "--hub                     <DOMAIN>               DockerHub name (or registry domain)"
			echo "--username                <USERNAME>             DockerHub username"
			echo "--password                <PASSWORD>             DockerHub password"
			echo
			echo "INSTALLATION MODE:"
			echo "--installationtype        <GROUPS|WORKSPACE|WORKSPACE_ENTERPRISE>"
			echo "                          Installation type"
			echo "--update                  <true|false>           Update existing components"
			echo
			echo "COMMUNITY SERVER OPTIONS:"
			echo "--communityimage          <NAME>|<.tar.gz>       Community-Server image name or .tar.gz"
			echo "--communityversion        <VERSION_TAG>          Community-Server version"
			echo "--installcs               <true|false|pull>      Install / skip / pre-pull Community Server"
			echo "--communityport           <PORT>                 External port (default: 80)"
			echo "--machinekey              <KEY>                  Value for core.machinekey"
			echo
			echo "DOCUMENT SERVER OPTIONS:"
			echo "--documentimage           <NAME>|<.tar.gz>       Document-Server image name or .tar.gz"
			echo "--documentversion         <VERSION_TAG>          Document-Server version"
			echo "--installdocs             <true|false|pull>      Install/Update Document Server"
			echo "--documentserverip        <IP>                   Document-Server IP (if external)"
			echo "--useasexternalserver     <true|false>           Expose services externally"
			echo
			echo "MAIL SERVER OPTIONS:"
			echo "--mailimage               <NAME>|<.tar.gz>       Mail-Server image name or .tar.gz"
			echo "--mailversion             <VERSION_TAG>          Mail-Server version"
			echo "--installmailserver       <true|false|pull>      Install/Update Mail Server"
			echo "--mailserverip            <IP>                   Mail-Server IP"
			echo "--mailserverdbip          <IP>                   Mail-Server DB IP"
			echo "--maildomain              <DOMAIN>               Mail domain name"
			echo
			echo "ELASTICSEARCH OPTIONS:"
			echo "--elasticsearchimage      <NAME>|<.tar.gz>       Elasticsearch image name or .tar.gz"
			echo "--elasticsearchversion    <VERSION_TAG>          Elasticsearch version"
			echo "--installelasticsearch    <true|false|pull>      Install/Update Elasticsearch"
			echo "--elasticsearchhost       <HOST>                 Elasticsearch host"
			echo "--elasticsearchport       <PORT>                 Elasticsearch port"
			echo
			echo "CONTROL PANEL OPTIONS:"
			echo "--controlpanelimage       <NAME>|<.tar.gz>       Control-Panel image name or .tar.gz"
			echo "--controlpanelversion     <VERSION_TAG>          Control-Panel version"
			echo "--installcontrolpanel     <true|false|pull>      Install/Update Control Panel"
			echo
			echo "DATABASE (MySQL) OPTIONS:"
			echo "--mysqlimage              <NAME>|<.tar.gz>       MySQL image name or .tar.gz"
			echo "--mysqlhost               <HOST>                 MySQL host"
			echo "--mysqlport               <PORT>                 MySQL port"
			echo "--mysqlrootuser           <USER>                 MySQL root user"
			echo "--mysqlrootpassword       <PASSWORD>             MySQL root password"
			echo "--mysqldatabase           <DB_NAME>              Community-Server DB name"
			echo "--mysqluser               <USERNAME>             Community-Server DB user"
			echo "--mysqlpassword           <PASSWORD>             Community-Server DB password"
			echo "--mysqlmaildatabase       <DB_NAME>              Mail-Server DB name"
			echo "--mysqlmailuser           <USERNAME>             Mail-Server DB user"
			echo "--mysqlmailpassword       <PASSWORD>             Mail-Server DB password"
			echo
			echo "JWT AUTHENTICATION:"
			echo "--jwtenabled              <true|false>           Enable JWT validation"
			echo "--jwtheader               <header_name>          HTTP header for JWT tokens (e.g., AuthorizationJwt)"
			echo "--jwtsecret               <secret>               JWT secret key (default: random key)"
			echo
			echo "ADVANCED OPTIONS:"
			echo "--partnerdatafile         <FILE>                 Partner data file"
			echo "--makeswap                <true|false>           Create swap file"
			echo "--skiphardwarecheck       <true|false>           Skip hardware check"
			echo "--skipversioncheck        <true|false>           Skip version check during update"
			echo "--skipdomaincheck         <true|false>           Skip mail domain check"
			echo
			echo "EXAMPLES:"
			echo "    Install all components with default settings:"
			echo "      sudo bash $HELP_TARGET --maildomain yourdomain.com"
			echo
			echo "    Install all the components without Mail Server:"
			echo "      sudo bash $HELP_TARGET --installmailserver false"
			echo
			echo "    Install Document Server only. Skip the installation of Mail Server, Community Server and Control Panel:"
			echo "      sudo bash $HELP_TARGET \\"
			echo "        --installcs false \\"
			echo "        --installdocs true \\"
			echo "        --installcontrolpanel false \\"
			echo "        --installmailserver false \\"
			echo "        --useasexternalserver true"
			echo
			echo "    Install Mail Server only. Skip the installation of Document Server, Community Server and Control Panel:"
			echo "      sudo bash $HELP_TARGET \\"
			echo "        --installcs false \\"
			echo "        --installdocs false \\"
			echo "        --installcontrolpanel false \\"
			echo "        --installmailserver true \\"
			echo "        --maildomain yourdomain.com \\"
			echo "        --useasexternalserver true"
			echo
			echo "    Install Community Server with Control Panel and connect it with Document Server installed on a different machine which has the 192.168.3.202 IP address:"
			echo "      sudo bash $HELP_TARGET \\"
			echo "        --installcs true \\"
			echo "        --installcontrolpanel true \\"
			echo "        --installdocs false \\"
			echo "        --installmailserver false \\"
			echo "        --documentserverip 192.168.3.202"
			echo
			echo "    Update all installed components. Stop the containers that need to be updated, remove them and run the latest versions of the corresponding components. The portal data should be picked up automatically:"
			echo "      sudo bash $HELP_TARGET --update true"
			echo
			echo "    Update Document Server only to version 4.4.2.20 and skip the update for all other components:"
			echo "      sudo bash $HELP_TARGET \\"
			echo "        --update true \\"
			echo "        --documentversion 4.4.2.20 \\"
			echo "        --installcs false \\"
			echo "        --installcontrolpanel false \\"
			echo "        --installmailserver false"
			echo
			echo "    Update Community Server only to version 12.7.1.1942 and skip the update for all other components:"
			echo "      sudo bash $HELP_TARGET \\"
			echo "        --update true \\"
			echo "        --communityversion 12.7.1.1942 \\"
			echo "        --installdocs false \\"
			echo "        --installcontrolpanel false \\"
			echo "        --installmailserver false"
			echo
			echo "    Update Mail Server only to version 1.6.27 and skip the update for all other components:"
			echo "      sudo bash $HELP_TARGET \\"
			echo "        --update true \\"
			echo "        --mailversion 1.6.27 \\"
			echo "        --installcs false \\"
			echo "        --installdocs false \\"
			echo "        --installcontrolpanel false"
			echo
			echo "    Update Control Panel only to version 2.1.0.93 and skip the update for all other components:"
			echo "      sudo bash $HELP_TARGET \\"
			echo "        --update true \\"
			echo "        --controlpanelversion 2.1.0.93 \\"
			echo "        --installcs false \\"
			echo "        --installdocs false \\"
			echo "        --installmailserver false"
			echo
			exit 0
		;;

		* )
			echo "Unknown parameter $1" 1>&2
			exit 1
		;;
	esac
	shift
done



root_checking () {
	if [ ! $( id -u ) -eq 0 ]; then
		echo "To perform this action you must be logged in with root rights"
		exit 1;
	fi
}

command_exists () {
    type "$1" &> /dev/null;
}

file_exists () {
	if [ -z "$1" ]; then
		echo "file path is empty"
		exit 1;
	fi

	if [ -f "$1" ]; then
		return 0; #true
	else
		return 1; #false
	fi
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

install_jq () {
	if command_exists apt-get; then
		apt-get -y update
		apt-get -y -q install jq
	elif command_exists yum; then
		rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-$REV.noarch.rpm || true
		yum -y install jq
	fi

	if ! command_exists jq; then
		echo "command jq not found"
		exit 1;
	fi
}

install_netstat () {
	if command_exists apt-get; then
		apt-get -y update
		apt-get -y -q install net-tools
	elif command_exists yum; then
		yum -y install net-tools
	fi

	if ! command_exists netstat; then
		echo "command netstat not found"
		exit 1;
	fi
}

to_lowercase () {
	echo "$1" | awk '{print tolower($0)}'
}

trim () {
	echo -e "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

get_os_info () {
	OS=`to_lowercase \`uname\``

	if [ "${OS}" == "windowsnt" ]; then
		echo "Not supported OS";
		exit 1;
	elif [ "${OS}" == "darwin" ]; then
		echo "Not supported OS";
		exit 1;
	else
		OS=`uname`

		if [ "${OS}" == "SunOS" ] ; then
			echo "Not supported OS";
			exit 1;
		elif [ "${OS}" == "AIX" ] ; then
			echo "Not supported OS";
			exit 1;
		elif [ "${OS}" == "Linux" ] ; then
			MACH=`uname -m`

			if [ "${MACH}" != "x86_64" ]; then
				echo "Currently only supports 64bit OS's";
				exit 1;
			fi

			KERNEL=`uname -r`

			if [ -f /etc/redhat-release ] ; then
				CONTAINS=$(cat /etc/redhat-release | { grep -sw release || true; });
				if [[ -n ${CONTAINS} ]]; then
					DIST=`cat /etc/redhat-release |sed s/\ release.*//`
					REV=`cat /etc/redhat-release | grep -oP '(?<=release )\d+'`
				else
					DIST=`cat /etc/os-release | grep -sw 'ID' | awk -F=  '{ print $2 }' | sed -e 's/^"//' -e 's/"$//'`
					REV=`cat /etc/os-release | grep -sw 'VERSION_ID' | awk -F=  '{ print $2 }' | sed -e 's/^"//' -e 's/"$//'`
				fi
			elif [ -f /etc/SuSE-release ] ; then
				REV=`cat /etc/os-release  | grep '^VERSION_ID' | awk -F=  '{ print $2 }' |  sed -e 's/^"//'  -e 's/"$//'`
				DIST='SuSe'
			elif [ -f /etc/debian_version ] ; then
				REV=`cat /etc/debian_version`
				DIST='Debian'
				if [ -f /etc/lsb-release ] ; then
					DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
					REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
				elif [ -f /etc/lsb_release ] || [ -f /usr/bin/lsb_release ] ; then
					DIST=`lsb_release -a 2>&1 | grep 'Distributor ID:' | awk -F ":" '{print $2 }'`
					REV=`lsb_release -a 2>&1 | grep 'Release:' | awk -F ":" '{print $2 }'`
				fi
			elif [ -f /etc/os-release ] ; then
				DIST=`cat /etc/os-release | grep -sw 'ID' | awk -F=  '{ print $2 }' | sed -e 's/^"//' -e 's/"$//'`
				REV=`cat /etc/os-release | grep -sw 'VERSION_ID' | awk -F=  '{ print $2 }' | sed -e 's/^"//' -e 's/"$//'`
			fi
		fi

		DIST=$(trim "$DIST");
		REV=$(trim $REV);
	fi
}

check_os_info () {
	if [[ -z ${KERNEL} || -z ${DIST} || -z ${REV} ]]; then
		echo "$KERNEL, $DIST, $REV";
		echo "Not supported OS";
		exit 1;
	fi
}

check_kernel () {
	MIN_NUM_ARR=(3 10 0);
	CUR_NUM_ARR=();

	CUR_STR_ARR=$(echo $KERNEL | grep -Po "[0-9]+\.[0-9]+\.[0-9]+" | tr "." " ");
	for CUR_STR_ITEM in $CUR_STR_ARR
	do
		CUR_NUM_ARR=(${CUR_NUM_ARR[@]} $CUR_STR_ITEM)
	done

	INDEX=0;

	while [[ $INDEX -lt 3 ]]; do
		if [ ${CUR_NUM_ARR[INDEX]} -lt ${MIN_NUM_ARR[INDEX]} ]; then
			echo "Not supported OS Kernel"
			exit 1;
		elif [ ${CUR_NUM_ARR[INDEX]} -gt ${MIN_NUM_ARR[INDEX]} ]; then
			INDEX=3
		fi
		(( INDEX++ ))
	done
}

check_hardware () {
	AVAILABLE_DISK_SPACE=$(df -m /  | tail -1 | awk '{ print $4 }');

	if [ ${AVAILABLE_DISK_SPACE} -lt ${DISK_REQUIREMENTS} ]; then
		echo "Minimal requirements are not met: need at least $DISK_REQUIREMENTS MB of free HDD space"
		exit 1;
	fi

	TOTAL_MEMORY=$(free --mega | grep -oP '\d+' | head -n 1);

	if [ ${TOTAL_MEMORY} -lt ${MEMORY_REQUIREMENTS} ]; then
		echo "Minimal requirements are not met: need at least $MEMORY_REQUIREMENTS MB of RAM"
		exit 1;
	fi

	CPU_CORES_NUMBER=$(cat /proc/cpuinfo | grep processor | wc -l);

	if [ ${CPU_CORES_NUMBER} -lt ${CORE_REQUIREMENTS} ]; then
		echo "The system does not meet the minimal hardware requirements. CPU with at least $CORE_REQUIREMENTS cores is required"
		exit 1;
	fi
}

make_swap () {
	DISK_REQUIREMENTS=6144; #6Gb free space
	MEMORY_REQUIREMENTS=16000; #RAM ~16Gb

	AVAILABLE_DISK_SPACE=$(df -m /  | tail -1 | awk '{ print $4 }');
	TOTAL_MEMORY=$(free --mega | grep -oP '\d+' | head -n 1);
	EXIST=$(swapon -s | awk '{ print $1 }' | { grep -x ${SWAPFILE} || true; });

	if [[ -z $EXIST ]] && [ ${TOTAL_MEMORY} -lt ${MEMORY_REQUIREMENTS} ] && [ ${AVAILABLE_DISK_SPACE} -gt ${DISK_REQUIREMENTS} ]; then

		if [ "${DIST}" == "Ubuntu" ] || [ "${DIST}" == "Debian" ]; then
			fallocate -l 6G ${SWAPFILE}
		else
			dd if=/dev/zero of=${SWAPFILE} count=6144 bs=1MiB
		fi

		chmod 600 ${SWAPFILE}
		mkswap ${SWAPFILE}
		swapon ${SWAPFILE}
		echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
	fi
}

check_ports () {
	RESERVED_PORTS=(443 5222 25 143 587 4190 8081 3306);
	ARRAY_PORTS=();
	USED_PORTS="";

	if ! command_exists netstat; then
		install_netstat
	fi

	if [ "${COMMUNITY_PORT//[0-9]}" = "" ]; then
		for RESERVED_PORT in "${RESERVED_PORTS[@]}"
		do
			if [ "$RESERVED_PORT" -eq "$COMMUNITY_PORT" ] ; then
				echo "Community port $COMMUNITY_PORT is reserved. Select another port"
				exit 1;
			fi
		done
	else
		echo "Invalid community port $COMMUNITY_PORT"
		exit 1;
	fi

	if [ "$INSTALL_COMMUNITY_SERVER" == "true" ]; then
		ARRAY_PORTS=(${ARRAY_PORTS[@]} "$COMMUNITY_PORT" "443" "5222");
	elif [ "$INSTALL_DOCUMENT_SERVER" == "true" ]; then
		if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
			ARRAY_PORTS=(${ARRAY_PORTS[@]} "$COMMUNITY_PORT" "443");
		fi
	fi

	if [ "$INSTALL_MAIL_SERVER" == "true" ]; then
		ARRAY_PORTS=(${ARRAY_PORTS[@]} "25" "143" "587", "465", "993", "995", "4190");

		if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
			ARRAY_PORTS=(${ARRAY_PORTS[@]} "8081");

			if [[ -z ${MYSQL_HOST} ]]; then
				ARRAY_PORTS=(${ARRAY_PORTS[@]} "3306");
			fi
		fi
	fi

	for PORT in "${ARRAY_PORTS[@]}"
	do
		REGEXP=":$PORT$"
		CHECK_RESULT=$(netstat -lnt | awk '{print $4}' | { grep $REGEXP || true; })

		if [[ $CHECK_RESULT != "" ]]; then
			if [[ $USED_PORTS != "" ]]; then
				USED_PORTS="$USED_PORTS, $PORT"
			else
				USED_PORTS="$PORT"
			fi
		fi
	done

	if [[ $USED_PORTS != "" ]]; then
		echo "The following TCP Ports must be available: $USED_PORTS"
		exit 1;
	fi
}

check_docker_version () {
	CUR_FULL_VERSION=$(docker -v | cut -d ' ' -f3 | cut -d ',' -f1);
	CUR_VERSION=$(echo $CUR_FULL_VERSION | cut -d '-' -f1);
	CUR_EDITION=$(echo $CUR_FULL_VERSION | cut -d '-' -f2);

	if [ "${CUR_EDITION}" == "ce" ] || [ "${CUR_EDITION}" == "ee" ]; then
		return 0;
	fi

	if [ "${CUR_VERSION}" != "${CUR_EDITION}" ]; then
		echo "Unspecific docker version"
		exit 1;
	fi

	MIN_NUM_ARR=(1 10 0);
	CUR_NUM_ARR=();

	CUR_STR_ARR=$(echo $CUR_VERSION | grep -Po "[0-9]+\.[0-9]+\.[0-9]+" | tr "." " ");

	for CUR_STR_ITEM in $CUR_STR_ARR
	do
		CUR_NUM_ARR=(${CUR_NUM_ARR[@]} $CUR_STR_ITEM)
	done

	INDEX=0;

	while [[ $INDEX -lt 3 ]]; do
		if [ ${CUR_NUM_ARR[INDEX]} -lt ${MIN_NUM_ARR[INDEX]} ]; then
			echo "The outdated Docker version has been found. Please update to the latest version."
			exit 1;
		elif [ ${CUR_NUM_ARR[INDEX]} -gt ${MIN_NUM_ARR[INDEX]} ]; then
			return 0;
		fi
		(( INDEX++ ))
	done
}

install_docker_using_script () {
	if ! command_exists curl ; then
		install_curl;
	fi

	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh
	rm get-docker.sh
}

install_docker () {

	if [ "${DIST}" == "Ubuntu" ] || [ "${DIST}" == "Debian" ] || [[ "${DIST}" == CentOS* ]] || [ "${DIST}" == "Fedora" ]; then

		install_docker_using_script
		systemctl start docker
		systemctl enable docker

	elif [[ "${DIST}" == Red\ Hat\ Enterprise\ Linux* ]]; then

		if [[ "${REV}" -gt "7" ]]; then
			yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc > null
			yum install -y yum-utils
			yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
			yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
			systemctl start docker
			systemctl enable docker
		else
			echo ""
			echo "Your operating system does not allow Docker CE installation."
			echo "You can install Docker EE using the manual here - https://docs.docker.com/engine/installation/linux/rhel/"
			echo ""
			exit 1
		fi

	elif [ "${DIST}" == "SuSe" ]; then

		echo ""
		echo "Your operating system does not allow Docker CE installation."
		echo "You can install Docker EE using the manual here - https://docs.docker.com/engine/installation/linux/suse/"
		echo ""
		exit 1;

	elif [ "${DIST}" == "altlinux" ]; then

		apt-get -y install docker-io
		chkconfig docker on
		service docker start
		systemctl enable docker

	else

		echo ""
		echo "Docker could not be installed automatically."
		echo "Please use this official instruction https://docs.docker.com/engine/installation/linux/other/ for its manual installation."
		echo ""
		exit 1;

	fi

	if ! command_exists docker ; then
		echo "error while installing docker"
		exit 1;
	fi
}

docker_login () {
	if [[ -n ${USERNAME} && -n ${PASSWORD}  ]]; then
		docker login ${HUB} --username ${USERNAME} --password ${PASSWORD}
	fi
}

make_directories () {
	mkdir -p "$BASE_DIR/setup";

	mkdir -p "$BASE_DIR/DocumentServer/data";
	mkdir -p "$BASE_DIR/DocumentServer/logs";
	mkdir -p "$BASE_DIR/DocumentServer/fonts";
	mkdir -p "$BASE_DIR/DocumentServer/forgotten";

	mkdir -p "$BASE_DIR/MailServer/data/certs";
	mkdir -p "$BASE_DIR/MailServer/logs";

	mkdir -p "$BASE_DIR/CommunityServer/data";
	mkdir -p "$BASE_DIR/CommunityServer/data/certs";
	mkdir -p "$BASE_DIR/CommunityServer/data/certs/tmp";
	mkdir -p "$BASE_DIR/CommunityServer/logs";

	mkdir -p "$BASE_DIR/ControlPanel/data";
	mkdir -p "$BASE_DIR/ControlPanel/logs";

	mkdir -p "$BASE_DIR/mysql/conf.d";
	mkdir -p "$BASE_DIR/mysql/data";
	mkdir -p "$BASE_DIR/mysql/initdb";
	mkdir -p "$BASE_DIR/mysql/logs";
	mkdir -p "$BASE_DIR/mysql/.private";
}

get_available_version () {
	if [[ -z "$1" ]]; then
		echo "image name is empty";
		exit 1;
	fi

	if ! command_exists curl ; then
		install_curl >/dev/null 2>&1
	fi

	if ! command_exists jq ; then
		install_jq >/dev/null 2>&1
	fi

	CREDENTIALS="";
	AUTH_HEADER="";
	TAGS_RESP="";

	if [[ -n ${HUB} ]]; then
		DOCKER_CONFIG="$HOME/.docker/config.json";

		if [[ -f "$DOCKER_CONFIG" ]]; then
			CREDENTIALS=$(jq -r '.auths."'$HUB'".auth' < "$DOCKER_CONFIG");
			if [ "$CREDENTIALS" == "null" ]; then
				CREDENTIALS="";
			fi
		fi

		if [[ -z ${CREDENTIALS} && -n ${USERNAME} && -n ${PASSWORD} ]]; then
			CREDENTIALS=$(echo -n "$USERNAME:$PASSWORD" | base64);
		fi

		if [[ -n ${CREDENTIALS} ]]; then
			AUTH_HEADER="Authorization: Basic $CREDENTIALS";
		fi

		REPO=$(echo $1 | sed "s/$HUB\///g");
		TAGS_RESP=$(curl -s -H "$AUTH_HEADER" -X GET https://$HUB/v2/$REPO/tags/list);
		TAGS_RESP=$(echo $TAGS_RESP | jq -r '.tags')
	else
		CREDENTIALS=${USERNAME:+${PASSWORD:+-u ${USERNAME}:${PASSWORD}}}
		TOKEN=$(curl -fs ${CREDENTIALS} "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${1}:pull" | jq -r .token)
		TAGS_RESP=$(curl -s -H "Authorization: Bearer ${TOKEN}" -X GET https://registry-1.docker.io/v2/$1/tags/list | jq -r '.tags | .[-100:] | .[]')
	fi

	VERSION_REGEX='^[0-9]+\.[0-9]+(\.[0-9]+){0,2}$'
	echo $(printf "%s\n" "${TAGS_RESP[@]}" | grep -E "$VERSION_REGEX" | sort -V | tail -n 1)
}

get_current_image_name () {
	if [[ -z "$1" ]]; then
		echo "container name is empty";
		exit 1;
	fi

	CONTAINER_IMAGE=$(docker inspect --format='{{.Config.Image}}' $1)

	CONTAINER_IMAGE_PARTS=($(echo $CONTAINER_IMAGE | tr ":" "\n"))

	echo ${CONTAINER_IMAGE_PARTS[0]}
}

get_current_image_version () {
	if [[ -z "$1" ]]; then
		echo "container name is empty";
		exit 1;
	fi

	CONTAINER_IMAGE=$(docker inspect --format='{{.Config.Image}}' $1)

	CONTAINER_IMAGE_PARTS=($(echo $CONTAINER_IMAGE | tr ":" "\n"))

	echo ${CONTAINER_IMAGE_PARTS[1]}
}

check_bindings () {
	if [[ -z "$1" ]]; then
		echo "container id is empty";
		exit 1;
	fi

	binds=$(docker inspect --format='{{range $p,$conf:=.HostConfig.Binds}}{{$conf}};{{end}}' $1)
	volumes=$(docker inspect --format='{{range $p,$conf:=.Config.Volumes}}{{$p}};{{end}}' $1)
	arrBinds=$(echo $binds | tr ";" "\n")
	arrVolumes=$(echo $volumes | tr ";" "\n")
	bindsCorrect=1

	if [[ -n "$2" ]]; then
		exceptions=$(echo $2 | tr "," "\n")
		for ex in ${exceptions[@]}
		do
			arrVolumes=(${arrVolumes[@]/$ex})
		done
	fi

	for volume in $arrVolumes
	do
		bindExist=0
		for bind in $arrBinds
		do
			bind=($(echo $bind | tr ":" " "))
			if [ "${bind[1]}" == "${volume}" ]; then
				bindExist=1
			fi
		done
		if [ "$bindExist" == "0" ]; then
			bindsCorrect=0
			echo "${volume} not binded"
		fi
	done

	if [ "$bindsCorrect" == "0" ]; then
		exit 1;
	fi
}

change_mysql_credentials () {
	while ! docker exec -it ${MYSQL_CONTAINER_NAME} mysqladmin ping --silent; do
		echo "wait for $MYSQL_CONTAINER_NAME"
		sleep 5
	done

	docker exec -it ${MYSQL_CONTAINER_NAME} mysqladmin password "$MYSQL_ROOT_PASSWORD"

	docker exec -i ${MYSQL_CONTAINER_NAME} mysql -u ${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} < ${BASE_DIR}/mysql/initdb/setup.sql
}

install_mysql_server () {
	MYSQL_SERVER_ID=$(get_container_id "$MYSQL_CONTAINER_NAME");

	RUN_MYSQL_SERVER="true";

	if [[ -n ${MYSQL_SERVER_ID} ]]; then
		RUN_MYSQL_SERVER="false";
		echo "ONLYOFFICE MYSQL SERVER is already installed."
		if [[ "$(awk -F. '{ printf("%d%03d%03d%03d", $1,$2,$3,$4); }' <<< $MYSQL_VERSION)" -lt "8000000000" ]]; then
			if ! grep -q "tls_version" ${BASE_DIR}/mysql/conf.d/${PRODUCT}.cnf; then
				echo "tls_version = TLSv1.2" >> ${BASE_DIR}/mysql/conf.d/${PRODUCT}.cnf 
				echo "" > $BASE_DIR/CommunityServer/data/.private/release_date
			else
				sed -i "s/tls_version.*/tls_version = TLSv1.2/" ${BASE_DIR}/mysql/conf.d/${PRODUCT}.cnf
			fi
		fi

		if file_exists "${BASE_DIR}/mysql/initdb/setup.sql"; then
			if grep -q "caching_sha2_password" ${BASE_DIR}/mysql/initdb/setup.sql; then
				sed -i 's/caching_sha2_password/mysql_native_password/g' ${BASE_DIR}/mysql/initdb/setup.sql
			elif ! grep -q "mysql_native_password" ${BASE_DIR}/mysql/initdb/setup.sql; then
				sed -i 's/IDENTIFIED BY/IDENTIFIED WITH mysql_native_password BY/g' ${BASE_DIR}/mysql/initdb/setup.sql
			fi
		fi

		docker restart ${MYSQL_SERVER_ID};
	fi

	if [ "$RUN_MYSQL_SERVER" == "true" ]; then

		if ! file_exists ${BASE_DIR}/mysql/conf.d/${PRODUCT}.cnf; then
			echo "[mysqld]
sql_mode = 'NO_ENGINE_SUBSTITUTION'
max_connections = 1000
max_allowed_packet = 1048576000
group_concat_max_len = 2048
log-error = /var/log/mysql/error.log" > ${BASE_DIR}/mysql/conf.d/${PRODUCT}.cnf
			[[ "$(awk -F. '{ printf("%d%03d%03d%03d", $1,$2,$3,$4); }' <<< $MYSQL_VERSION)" -lt "8000000000" ]] && echo "tls_version = TLSv1.2" >> ${BASE_DIR}/mysql/conf.d/${PRODUCT}.cnf
			chmod 0644 ${BASE_DIR}/mysql/conf.d/${PRODUCT}.cnf
		fi

		if ! file_exists ${BASE_DIR}/mysql/initdb/setup.sql; then
                        echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASSWORD';
CREATE USER '$MYSQL_MAIL_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_MAIL_ROOT_PASSWORD';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_ROOT_USER'@'%';
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_MAIL_USER'@'%';
FLUSH PRIVILEGES;" > ${BASE_DIR}/mysql/initdb/setup.sql
        fi



		if ! file_exists ${BASE_DIR}/mysql/logs/error.log; then
			chown 999:999 ${BASE_DIR}/mysql/logs;
		fi


		if [ "$UPDATE" == "true" ]; then
			echo "copying $MYSQL_DATABASE database mysql files"
			cp -rf ${BASE_DIR}/CommunityServer/mysql/. ${BASE_DIR}/mysql/data
			MOVE_COMMUNITY_SERVER_DATABASE="true";
		fi

		args=();
		args+=(--name "$MYSQL_CONTAINER_NAME");

		if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
			args+=(-p 3306:3306);
		fi

		args+=(-v "$BASE_DIR/mysql/conf.d:/etc/mysql/conf.d");
		args+=(-v "$BASE_DIR/mysql/data:/var/lib/mysql");
		args+=(-v "$BASE_DIR/mysql/initdb:/docker-entrypoint-initdb.d");
		args+=(-v "$BASE_DIR/mysql/logs:/var/log/mysql");
		args+=(-e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD");
		args+=(-e "MYSQL_DATABASE=$MYSQL_DATABASE");
		args+=("$MYSQL_IMAGE_NAME:$MYSQL_VERSION");

		docker run --net ${NETWORK} -i -t -d --restart=always "${args[@]}";

		MYSQL_SERVER_ID=$(get_container_id "$MYSQL_CONTAINER_NAME");

		if [[ -z ${MYSQL_SERVER_ID} ]]; then
			echo "ONLYOFFICE MYSQL SERVER not installed."
			exit 1;
		fi

		if [ "$UPDATE" == "true" ]; then
			change_mysql_credentials
		fi
	fi
}

install_document_server () {
	DOCUMENT_SERVER_ID=$(get_container_id "$DOCUMENT_CONTAINER_NAME");

	RUN_DOCUMENT_SERVER="true";

	if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			CURRENT_IMAGE_NAME=$(get_current_image_name "$DOCUMENT_CONTAINER_NAME");
			CURRENT_IMAGE_VERSION=$(get_current_image_version "$DOCUMENT_CONTAINER_NAME");

			if [ "$CURRENT_IMAGE_NAME" == "onlyoffice/documentserver" ]; then
				ACTIVATE_COMMUNITY_SERVER_TRIAL="true";
			fi

			if [ "$CURRENT_IMAGE_NAME" != "$DOCUMENT_IMAGE_NAME" ] || ([ "$CURRENT_IMAGE_VERSION" != "$DOCUMENT_VERSION" ] || [ "$SKIP_VERSION_CHECK" == "true" ]); then
				check_bindings $DOCUMENT_SERVER_ID "/etc/$PRODUCT,/var/lib/$PRODUCT,/var/lib/postgresql,/usr/share/fonts/truetype/custom,/var/lib/rabbitmq,/var/lib/redis";
				docker exec ${DOCUMENT_CONTAINER_NAME} bash /usr/bin/documentserver-prepare4shutdown.sh
				remove_container ${DOCUMENT_CONTAINER_NAME}
			else
				RUN_DOCUMENT_SERVER="false";
				echo "The latest version of ONLYOFFICE DOCUMENT SERVER is already installed."
				docker start ${DOCUMENT_SERVER_ID};
			fi
		else
			RUN_DOCUMENT_SERVER="false";
			echo "ONLYOFFICE DOCUMENT SERVER is already installed."
			docker start ${DOCUMENT_SERVER_ID};
		fi
	else
		RESTART_COMMUNITY_SERVER="true";
	fi

	if [ "$RUN_DOCUMENT_SERVER" == "true" ]; then
		args=();
		args+=(--name "$DOCUMENT_CONTAINER_NAME");
		args+=(--expose 8000);

		if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
			args+=(-p 80:80);
			args+=(-p 443:443);
		fi

		if [[ -n ${JWT_SECRET} ]]; then
			args+=(-e "JWT_ENABLED=$JWT_ENABLED");
			args+=(-e "JWT_HEADER=$JWT_HEADER");
			args+=(-e "JWT_SECRET=$JWT_SECRET");
		else
			args+=(-e "JWT_ENABLED=false");
		fi

		args+=(-v "$BASE_DIR/DocumentServer/data:/var/www/$PRODUCT/Data");
		args+=(-v "$BASE_DIR/DocumentServer/logs:/var/log/$PRODUCT");
		args+=(-v "$BASE_DIR/DocumentServer/fonts:/usr/share/fonts/truetype/custom");
		args+=(-v "$BASE_DIR/DocumentServer/forgotten:/var/lib/$PRODUCT/documentserver/App_Data/cache/files/forgotten");
		args+=("$DOCUMENT_IMAGE_NAME:$DOCUMENT_VERSION");

		docker run --net ${NETWORK} -i -t -d --restart=always "${args[@]}";

		DOCUMENT_SERVER_ID=$(get_container_id "$DOCUMENT_CONTAINER_NAME");

		if [[ -z ${DOCUMENT_SERVER_ID} ]]; then
			echo "ONLYOFFICE DOCUMENT SERVER not installed."
			exit 1;
		else
			COMMUNITY_SERVER_ID=$(get_container_id "$COMMUNITY_CONTAINER_NAME");

			if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
				docker exec ${COMMUNITY_CONTAINER_NAME} chown -R ${PRODUCT}:${PRODUCT} /var/www/${PRODUCT}/DocumentServerData
			fi
		fi
	fi
}

install_mail_server () {
	MAIL_SERVER_ID=$(get_container_id "$MAIL_CONTAINER_NAME");
	MYSQL_SERVER_ID=$(get_container_id "$MYSQL_CONTAINER_NAME");
	HOSTNAME_IPS=$(hostname -i);
	IP_V4_REGEX="([0-9]{1,3}\.){3}[0-9]{1,3}";
	RUN_MAIL_SERVER="true";

	if [[ -n ${MAIL_SERVER_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			CURRENT_IMAGE_NAME=$(get_current_image_name "$MAIL_CONTAINER_NAME");
			CURRENT_IMAGE_VERSION=$(get_current_image_version "$MAIL_CONTAINER_NAME");

			MOVE_DATABASE="false";
			if [[ -z ${MYSQL_HOST} ]] && [[ -n ${MYSQL_SERVER_ID} ]]; then
				EXIST_DATABASE=$(docker exec -i ${MYSQL_CONTAINER_NAME} mysql -s -N -u ${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -e "show databases;" 2>/dev/null | { grep -sw ${MYSQL_MAIL_DATABASE} || true; });
				if [[ -z ${EXIST_DATABASE} ]]; then
					MOVE_DATABASE="true";
				fi
			fi

			if [ "$CURRENT_IMAGE_NAME" != "$MAIL_IMAGE_NAME" ] || ([ "$CURRENT_IMAGE_VERSION" != "$MAIL_VERSION" ] || [ "$SKIP_VERSION_CHECK" == "true" ]) || [ "$MOVE_DATABASE" == "true" ]; then
				check_bindings $MAIL_SERVER_ID "/var/lib/mysql";
				MAIL_DOMAIN_NAME=$(docker exec $MAIL_SERVER_ID hostname -f);

				if [ "$MOVE_DATABASE" == "true" ]; then
					move_mail_server_database
				fi

				stop_mail_server_mysql
				remove_container ${MAIL_CONTAINER_NAME}
			else
				RUN_MAIL_SERVER="false";
				echo "The latest version of ONLYOFFICE MAIL SERVER is already installed."
				docker start ${MAIL_SERVER_ID};
			fi
		else
			RUN_MAIL_SERVER="false";
			echo "ONLYOFFICE MAIL SERVER is already installed."
			docker start ${MAIL_SERVER_ID};
		fi
	else
		RESTART_COMMUNITY_SERVER="true";
	fi

	if [ "$RUN_MAIL_SERVER" == "true" ]; then
		if [[ -n ${MAIL_DOMAIN_NAME} ]]; then
			args=();
			args+=(--name "$MAIL_CONTAINER_NAME");
			args+=(-p 25:25);
			args+=(-p 143:143);
			args+=(-p 587:587);
			args+=(-p 465:465);
			args+=(-p 993:993);
			args+=(-p 995:995);
			args+=(-p 4190:4190);

			MAIL_SERVER_ADDITIONAL_PORTS="";

			if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
				args+=(-p 8081:8081);

				if [[ -z ${MYSQL_SERVER_ID} ]]; then
					args+=(-p 3306:3306);
				fi

				for ip in ${HOSTNAME_IPS}
				do
					if [[ $ip =~ $IP_V4_REGEX ]]; then
						args+=(--add-host="$MAIL_DOMAIN_NAME:$ip");
					fi
				done
			fi

			MYSQL_SERVER="";

			if [[ -n ${MYSQL_SERVER_ID} ]]; then
				MYSQL_SERVER="$MYSQL_CONTAINER_NAME";
			elif [[ -n ${MYSQL_HOST} ]]; then
				MYSQL_SERVER="$MYSQL_HOST";
			fi

			if [[ -n ${MYSQL_SERVER} ]]; then
				args+=(-e "MYSQL_SERVER=$MYSQL_SERVER");
				args+=(-e "MYSQL_SERVER_PORT=$MYSQL_PORT");
				args+=(-e "MYSQL_ROOT_USER=$MYSQL_ROOT_USER");
				args+=(-e "MYSQL_ROOT_PASSWD=$MYSQL_ROOT_PASSWORD");
				args+=(-e "MYSQL_SERVER_DB_NAME=$MYSQL_MAIL_DATABASE");
			fi

			args+=(-v "$BASE_DIR/MailServer/data:/var/vmail");
			args+=(-v "$BASE_DIR/MailServer/data/certs:/etc/pki/tls/mailserver");
			args+=(-v "$BASE_DIR/MailServer/logs:/var/log");
			args+=(-h "$MAIL_DOMAIN_NAME");
			args+=("$MAIL_IMAGE_NAME:$MAIL_VERSION");

			MAJOR_DOCKER_VERSION=$(docker -v | cut -d ' ' -f3 | cut -d ',' -f1 | cut -d '-' -f1 | cut -d '.' -f1);

			if [ ${MAJOR_DOCKER_VERSION} -ge 17 ]; then
				docker run --init --net ${NETWORK} --privileged -i -t -d --restart=always "${args[@]}";
			else
				docker run --net ${NETWORK} --privileged -i -t -d --restart=always "${args[@]}";
			fi

			MAIL_SERVER_ID=$(get_container_id "$MAIL_CONTAINER_NAME");

			if [[ -z ${MAIL_SERVER_ID} ]]; then
				echo "ONLYOFFICE MAIL SERVER not installed."
				exit 1;
			fi
		else
			echo "mail domain is not specified."
		fi
	fi
}

install_elasticsearch () {
	ELASTICSEARCH_ID=$(get_container_id "$ELASTICSEARCH_CONTAINER_NAME");
	RUN_ELASTICSEARCH="true";

	if [[ -n ${ELASTICSEARCH_ID} ]]; then
		ELASTICSEARCH_SERVER="$ELASTICSEARCH_CONTAINER_NAME";
		if [ "$UPDATE" == "true" ]; then
			CURRENT_IMAGE_NAME=$(get_current_image_name "$ELASTICSEARCH_CONTAINER_NAME");
			CURRENT_IMAGE_VERSION=$(get_current_image_version "$ELASTICSEARCH_CONTAINER_NAME");

			if [ "$CURRENT_IMAGE_NAME" != "$ELASTICSEARCH_IMAGE_NAME" ] || \
			   [ "$CURRENT_IMAGE_VERSION" != "$ELASTICSEARCH_VERSION" ] || \
			   [ "$SKIP_VERSION_CHECK" == "true" ]; then
				check_bindings $ELASTICSEARCH_ID "/usr/share/elasticsearch/data";
				remove_container ${ELASTICSEARCH_CONTAINER_NAME}
			else
				RUN_ELASTICSEARCH="false";
				echo "The latest version of ELASTICSEARCH is already installed."
				docker start ${ELASTICSEARCH_ID};
			fi
		else
			RUN_ELASTICSEARCH="false";
			echo "ELASTICSEARCH is already installed."
			docker start ${ELASTICSEARCH_ID};
		fi
	else
		RESTART_COMMUNITY_SERVER="true";
	fi

	if [ "$RUN_ELASTICSEARCH" == "true" ]; then
		args=();
		args+=(--name "$ELASTICSEARCH_CONTAINER_NAME");

		args+=(-e "discovery.type=single-node");
		args+=(-e "bootstrap.memory_lock=true");
		args+=(-e "ingest.geoip.downloader.enabled=false");
		
		MEMORY_REQUIREMENTS=12228; #RAM ~12Gb
		if [ ${TOTAL_MEMORY} -gt ${MEMORY_REQUIREMENTS} ]; then
			args+=(-e "ES_JAVA_OPTS=-Xms4g -Xmx4g -Dlog4j2.formatMsgNoLookups=true");
		else
			args+=(-e "ES_JAVA_OPTS=-Xms1g -Xmx1g -Dlog4j2.formatMsgNoLookups=true");
		fi

		args+=(-e "indices.fielddata.cache.size=30%");
		args+=(-e "indices.memory.index_buffer_size=30%");
		args+=(--ulimit "nofile=65535:65535");
		args+=(--ulimit "memlock=-1:-1");
		
		if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
			args+=(-p 9200:9200);
			args+=(-p 9300:9300);
		fi

		args+=(-v "$BASE_DIR/elasticsearch/data:/usr/share/elasticsearch/data");
		args+=("$ELASTICSEARCH_IMAGE_NAME:$ELASTICSEARCH_VERSION");

		docker run --net ${NETWORK} -i -t -d --restart=always "${args[@]}";
		chown -R 1000:1000 $BASE_DIR/elasticsearch #fix AccessDeniedException[/usr/share/elasticsearch/data/nodes]
		ELASTICSEARCH_ID=$(get_container_id "$ELASTICSEARCH_CONTAINER_NAME");

		if [[ -n ${ELASTICSEARCH_ID} ]]; then
			ELASTICSEARCH_SERVER="$ELASTICSEARCH_CONTAINER_NAME";
		elif [[ -z ${ELASTICSEARCH_ID} ]]; then
			echo "ELASTICSEARCH not installed."
			exit 1;
		fi
	fi
}

install_controlpanel () {
	CONTROL_PANEL_ID=$(get_container_id "$CONTROLPANEL_CONTAINER_NAME");

	RUN_CONTROL_PANEL="true";

	if [[ -n ${CONTROL_PANEL_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			CURRENT_IMAGE_NAME=$(get_current_image_name "$CONTROLPANEL_CONTAINER_NAME");
			CURRENT_IMAGE_VERSION=$(get_current_image_version "$CONTROLPANEL_CONTAINER_NAME");

			if [ "$CURRENT_IMAGE_NAME" != "$CONTROLPANEL_IMAGE_NAME" ] || ([ "$CURRENT_IMAGE_VERSION" != "$CONTROLPANEL_VERSION" ] || [ "$SKIP_VERSION_CHECK" == "true" ]); then
				check_bindings $CONTROL_PANEL_ID "/var/lib/mysql";
				remove_container ${CONTROLPANEL_CONTAINER_NAME}
			else
				RUN_CONTROL_PANEL="false";
				echo "The latest version of ONLYOFFICE CONTROL PANEL is already installed."
				docker start ${CONTROL_PANEL_ID};
			fi
		else
			RUN_CONTROL_PANEL="false";
			echo "ONLYOFFICE CONTROL PANEL is already installed."
			docker start ${CONTROL_PANEL_ID};
		fi
	else
		RESTART_COMMUNITY_SERVER="true";
	fi

	if [ "$RUN_CONTROL_PANEL" == "true" ]; then
		args=();
		args+=(--name "$CONTROLPANEL_CONTAINER_NAME");

		if [[ -n ${MAIL_SERVER_API_HOST} ]]; then
			args+=(-e "MAIL_SERVER_EXTERNAL=true");
		fi

		if [[ -n ${DOCUMENT_SERVER_HOST} ]]; then
			args+=(-e "DOCUMENT_SERVER_EXTERNAL=true");
		fi

		if [[ -n ${COMMUNITY_SERVER_HOST} ]]; then
			args+=(-e "COMMUNITY_SERVER_EXTERNAL=true");
		fi

		if [[ -n ${CORE_MACHINEKEY} ]]; then
			args+=(-e "$MACHINEKEY_PARAM=$CORE_MACHINEKEY");
		fi

		args+=(-v "/var/run/docker.sock:/var/run/docker.sock");
		args+=(-v "$BASE_DIR/CommunityServer/data:/app/$PRODUCT/CommunityServer/data");
		args+=(-v "$BASE_DIR/ControlPanel/data:/var/www/$PRODUCT/Data");
		args+=(-v "$BASE_DIR/ControlPanel/logs:/var/log/$PRODUCT");
		args+=("$CONTROLPANEL_IMAGE_NAME:$CONTROLPANEL_VERSION");

		docker run --net ${NETWORK} -i -t -d --restart=always "${args[@]}";

		CONTROL_PANEL_ID=$(get_container_id "$CONTROLPANEL_CONTAINER_NAME");

		if [[ -z ${CONTROL_PANEL_ID} ]]; then
			echo "ONLYOFFICE CONTROL PANEL not installed."
			exit 1;
		fi
	fi
}

install_community_server () {
	COMMUNITY_SERVER_ID=$(get_container_id "$COMMUNITY_CONTAINER_NAME");
	DOCUMENT_SERVER_ID=$(get_container_id "$DOCUMENT_CONTAINER_NAME");
	MAIL_SERVER_ID=$(get_container_id "$MAIL_CONTAINER_NAME");
	CONTROL_PANEL_ID=$(get_container_id "$CONTROLPANEL_CONTAINER_NAME");
	MYSQL_SERVER_ID=$(get_container_id "$MYSQL_CONTAINER_NAME");

	RUN_COMMUNITY_SERVER="true";

	if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
		docker exec -d ${COMMUNITY_CONTAINER_NAME} bash -c "cp -rf /var/www/${PRODUCT}/WebStudio/App_Data/static/partnerdata /var/www/${PRODUCT}/Data/"

		if [ "$UPDATE" == "true" ]; then
			CURRENT_IMAGE_NAME=$(get_current_image_name "$COMMUNITY_CONTAINER_NAME");
			CURRENT_IMAGE_VERSION=$(get_current_image_version "$COMMUNITY_CONTAINER_NAME");

			if [ "$CURRENT_IMAGE_NAME" != "$COMMUNITY_IMAGE_NAME" ] || ([ "$CURRENT_IMAGE_VERSION" != "$COMMUNITY_VERSION" ] || [ "$SKIP_VERSION_CHECK" == "true" ]) || [ "$MOVE_COMMUNITY_SERVER_DATABASE" == "true" ]; then
				check_bindings $COMMUNITY_SERVER_ID "/var/lib/mysql";
				COMMUNITY_PORT=$(docker port $COMMUNITY_SERVER_ID 80 | sed 's/.*://' | head -n1)
				stop_community_server_mysql
				remove_container ${COMMUNITY_CONTAINER_NAME}
			else
				RUN_COMMUNITY_SERVER="false";

				if [ "$ACTIVATE_COMMUNITY_SERVER_TRIAL" == "true" ]; then
					docker restart ${COMMUNITY_CONTAINER_NAME}
				fi

				echo "The latest version of ONLYOFFICE COMMUNITY SERVER is already installed."
				docker start ${COMMUNITY_SERVER_ID};
			fi
		else
			if [ "$RESTART_COMMUNITY_SERVER" == "true" ]; then
				check_bindings $COMMUNITY_SERVER_ID "/var/lib/mysql";
				COMMUNITY_PORT=$(docker port $COMMUNITY_SERVER_ID 80 | sed 's/.*://' | head -n1)
				stop_community_server_mysql
				remove_container ${COMMUNITY_CONTAINER_NAME}
			else
				RUN_COMMUNITY_SERVER="false";
				echo "ONLYOFFICE COMMUNITY SERVER is already installed."
				docker start ${COMMUNITY_SERVER_ID};
			fi
		fi
	fi

	if [ "$RUN_COMMUNITY_SERVER" == "true" ]; then
		args=();
		args+=(--name "$COMMUNITY_CONTAINER_NAME");
		args+=(-p "$COMMUNITY_PORT:80");
		args+=(-p 443:443);
		args+=(-p 5222:5222);
		args+=(--cgroupns host);

		if [[ -n ${MAIL_SERVER_API_HOST} ]]; then
			args+=(-e "MAIL_SERVER_API_HOST=$MAIL_SERVER_API_HOST");

			if [[ -n ${MAIL_SERVER_DB_HOST} ]]; then
				args+=(-e "MAIL_SERVER_DB_HOST=$MAIL_SERVER_DB_HOST");
			else
				args+=(-e "MAIL_SERVER_DB_HOST=$MAIL_SERVER_API_HOST");
			fi
		fi

		if [[ -n ${MAIL_DOMAIN_NAME} ]]; then
			args+=(-e "MAIL_DOMAIN_NAME=$MAIL_DOMAIN_NAME");
		fi

		if [[ -n ${DOCUMENT_SERVER_HOST} ]]; then
			args+=(-e "DOCUMENT_SERVER_HOST=$DOCUMENT_SERVER_HOST");
		fi

		if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
			args+=(-e "DOCUMENT_SERVER_PORT_80_TCP_ADDR=$DOCUMENT_CONTAINER_NAME");
		fi

		MYSQL_SERVER="";

		if [[ -n ${MYSQL_SERVER_ID} ]]; then
			MYSQL_SERVER="$MYSQL_CONTAINER_NAME";
		elif [[ -n ${MYSQL_HOST} ]]; then
			MYSQL_SERVER="$MYSQL_HOST";
		fi

		if [[ -n ${MYSQL_SERVER} ]]; then
			args+=(-e "MYSQL_SERVER_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD");
			args+=(-e "MYSQL_SERVER_DB_NAME=$MYSQL_DATABASE");
			args+=(-e "MYSQL_SERVER_HOST=$MYSQL_SERVER");
			args+=(-e "MYSQL_SERVER_USER=$MYSQL_USER");
			args+=(-e "MYSQL_SERVER_PASS=$MYSQL_PASSWORD");
		fi

		if [[ -n ${ELASTICSEARCH_SERVER} ]]; then
			args+=(-e "ELASTICSEARCH_SERVER_HOST=$ELASTICSEARCH_SERVER");
			args+=(-e "ELASTICSEARCH_SERVER_HTTPPORT=$ELASTICSEARCH_PORT");
		fi

		if [[ -n ${MAIL_SERVER_ID} ]]; then
			args+=(-e "MAIL_SERVER_API_HOST=$MAIL_CONTAINER_NAME");

			if [[ -n ${MYSQL_SERVER} ]]; then
				args+=(-e "MAIL_SERVER_DB_HOST=$MYSQL_SERVER");
				args+=(-e "MAIL_SERVER_DB_NAME=$MYSQL_MAIL_DATABASE");
				args+=(-e "MAIL_SERVER_DB_PORT=$MYSQL_PORT");
				args+=(-e "MAIL_SERVER_DB_USER=$MYSQL_ROOT_USER");
				args+=(-e "MAIL_SERVER_DB_PASS=$MYSQL_ROOT_PASSWORD");
			else
				args+=(-e "MAIL_SERVER_DB_HOST=$MAIL_CONTAINER_NAME");
			fi
		fi

		if [[ -n ${MAIL_IMAPSYNC_START_DATE} ]]; then
			args+=(-e "MAIL_IMAPSYNC_START_DATE=$MAIL_IMAPSYNC_START_DATE");
		fi

		if [[ -n ${CONTROL_PANEL_ID} ]]; then
			args+=(-e "CONTROL_PANEL_PORT_80_TCP=80");
			args+=(-e "CONTROL_PANEL_PORT_80_TCP_ADDR=$CONTROLPANEL_CONTAINER_NAME");
		fi

		if [[ -n ${JWT_SECRET} ]]; then
			args+=(-e "DOCUMENT_SERVER_JWT_ENABLED=$JWT_ENABLED");
			args+=(-e "DOCUMENT_SERVER_JWT_HEADER=$JWT_HEADER");
			args+=(-e "DOCUMENT_SERVER_JWT_SECRET=$JWT_SECRET");
		else
			args+=(-e "DOCUMENT_SERVER_JWT_ENABLED=false");
		fi

		if [[ -n ${CORE_MACHINEKEY} ]]; then
			args+=(-e "$MACHINEKEY_PARAM=$CORE_MACHINEKEY");
		fi

		args+=(-v "$BASE_DIR/CommunityServer/letsencrypt:/etc/letsencrypt");
		args+=(-v "/sys/fs/cgroup:/sys/fs/cgroup:rw");
		args+=(-v "$BASE_DIR/CommunityServer/data:/var/www/$PRODUCT/Data");
		args+=(-v "$BASE_DIR/CommunityServer/logs:/var/log/$PRODUCT");
		args+=(-v "$BASE_DIR/DocumentServer/data:/var/www/$PRODUCT/DocumentServerData");
		args+=("$COMMUNITY_IMAGE_NAME:$COMMUNITY_VERSION");

		docker run --net ${NETWORK} -itd  --privileged --restart=always "${args[@]}";

		COMMUNITY_SERVER_ID=$(get_container_id "$COMMUNITY_CONTAINER_NAME");

		if [[ -z ${COMMUNITY_SERVER_ID} ]]; then
			echo "ONLYOFFICE COMMUNITY SERVER not installed."
			exit 1;
		else
			docker exec -d ${COMMUNITY_CONTAINER_NAME} bash -c "[ -d /var/www/${PRODUCT}/Data/partnerdata ] && cp /var/www/${PRODUCT}/Data/partnerdata/* /var/www/${PRODUCT}/WebStudio/App_Data/static/partnerdata/ && rm -rf /var/www/${PRODUCT}/Data/partnerdata"
		fi
	fi
}

get_container_id () {
	CONTAINER_NAME=$1;

	if [[ -z ${CONTAINER_NAME} ]]; then
		echo "Empty container name"
		exit 1;
	fi

	CONTAINER_ID="";

	CONTAINER_EXIST=$(docker ps -aqf "name=$CONTAINER_NAME");

	if [[ -n ${CONTAINER_EXIST} ]]; then
		CONTAINER_ID=$(docker inspect --format='{{.Id}}' ${CONTAINER_NAME});
	fi

	echo "$CONTAINER_ID"
}

get_container_ip () {
	CONTAINER_NAME=$1;

	if [[ -z ${CONTAINER_NAME} ]]; then
		echo "Empty container name"
		exit 1;
	fi

	CONTAINER_IP="";

	CONTAINER_EXIST=$(docker ps -aqf "name=$CONTAINER_NAME");

	if [[ -n ${CONTAINER_EXIST} ]]; then
		CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINER_NAME});
	fi

	echo "$CONTAINER_IP"
}

get_random_str () {
	LENGTH=$1;

	if [[ -z ${LENGTH} ]]; then
		LENGTH=12;
	fi

	VALUE=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c ${LENGTH});
	echo "$VALUE"
}

set_jwt_secret () {
	CURRENT_JWT_SECRET="";

	if [[ -z ${JWT_SECRET} ]]; then
		CURRENT_JWT_SECRET=$(get_container_env_parameter "$DOCUMENT_CONTAINER_NAME" "JWT_SECRET");

		if [[ -n ${CURRENT_JWT_SECRET} ]]; then
			JWT_SECRET="$CURRENT_JWT_SECRET";
		fi
	fi

	if [[ -z ${JWT_SECRET} ]]; then
		CURRENT_JWT_SECRET=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "DOCUMENT_SERVER_JWT_SECRET");

		if [[ -n ${CURRENT_JWT_SECRET} ]]; then
			JWT_SECRET="$CURRENT_JWT_SECRET";
		fi
	fi

	if [[ -z ${JWT_SECRET} ]] && [[ "$USE_AS_EXTERNAL_SERVER" != "true" ]]; then
		JWT_SECRET=$(get_random_str 32);
		[ $JWT_ENABLED = "true" ] && JWT_MESSAGE='JWT is enabled by default. A random secret is generated automatically. Run the command "docker exec $(sudo docker ps -q) sudo documentserver-jwt-status.sh" to get information about JWT.'
	fi
}

set_jwt_header () {
	CURRENT_JWT_HEADER="";

	if [[ -z ${JWT_HEADER} ]]; then
		CURRENT_JWT_HEADER=$(get_container_env_parameter "$DOCUMENT_CONTAINER_NAME" "JWT_HEADER");

		if [[ -n ${CURRENT_JWT_HEADER} ]]; then
			JWT_HEADER="$CURRENT_JWT_HEADER";
		fi
	fi	
	
	if [[ -z ${JWT_HEADER} ]]; then
		CURRENT_JWT_HEADER=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "DOCUMENT_SERVER_JWT_HEADER");

		if [[ -n ${CURRENT_JWT_HEADER} ]]; then
			JWT_HEADER="$CURRENT_JWT_HEADER";
		fi
	fi

	if [[ -z ${JWT_HEADER} ]]; then
		JWT_HEADER="AuthorizationJwt"
	fi
}


set_jwt_enabled () {
	CURRENT_JWT_ENABLED="";

	if [[ -z ${JWT_ENABLED} ]]; then
		CURRENT_JWT_ENABLED=$(get_container_env_parameter "$DOCUMENT_CONTAINER_NAME" "JWT_ENABLED");

		if [[ -n ${CURRENT_JWT_ENABLED} ]]; then
			JWT_ENABLED="$CURRENT_JWT_ENABLED";
		fi
	fi

	if [[ -z ${JWT_ENABLED} ]]; then
		CURRENT_JWT_ENABLED=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "DOCUMENT_SERVER_JWT_ENABLED");

		if [[ -n ${CURRENT_JWT_ENABLED} ]]; then
			JWT_ENABLED="$CURRENT_JWT_ENABLED";
		fi
	fi

	if [[ -z ${JWT_ENABLED} ]]; then
		JWT_ENABLED="true"
	fi
}

set_core_machinekey () {
	CURRENT_CORE_MACHINEKEY="";

	if [[ -z ${CORE_MACHINEKEY} ]]; then
		if file_exists ${BASE_DIR}/CommunityServer/data/.private/machinekey; then
			CURRENT_CORE_MACHINEKEY=$(cat ${BASE_DIR}/CommunityServer/data/.private/machinekey);

			if [[ -n ${CURRENT_CORE_MACHINEKEY} ]]; then
				CORE_MACHINEKEY="$CURRENT_CORE_MACHINEKEY";
			fi
		fi
	fi

	if [[ -z ${CORE_MACHINEKEY} ]]; then
		CURRENT_CORE_MACHINEKEY=$(get_container_env_parameter "$CONTROLPANEL_CONTAINER_NAME" "$MACHINEKEY_PARAM");

		if [[ -n ${CURRENT_CORE_MACHINEKEY} ]]; then
			CORE_MACHINEKEY="$CURRENT_CORE_MACHINEKEY";
		fi
	fi

	if [[ -z ${CORE_MACHINEKEY} ]]; then
		CURRENT_CORE_MACHINEKEY=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "$MACHINEKEY_PARAM");

		if [[ -n ${CURRENT_CORE_MACHINEKEY} ]]; then
			CORE_MACHINEKEY="$CURRENT_CORE_MACHINEKEY";
		fi
	fi

	if [[ -z ${CORE_MACHINEKEY} ]] && [[ "$UPDATE" != "true" ]] && [[ "$USE_AS_EXTERNAL_SERVER" != "true" ]]; then
		CORE_MACHINEKEY=$(get_random_str 12);
	fi
}

read_parameters () {
	COMMUNITY_SERVER_ID=$(get_container_id "$COMMUNITY_CONTAINER_NAME");
	MAIL_SERVER_ID=$(get_container_id "$MAIL_CONTAINER_NAME");
	PARAMETER_VALUE="";

	if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
		PARAMETER_VALUE=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "MYSQL_SERVER_HOST");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_HOST="$PARAMETER_VALUE";
			if [ "$MYSQL_HOST" == "$MYSQL_CONTAINER_NAME" ]; then
				MYSQL_HOST="";
			fi
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "MYSQL_SERVER_ROOT_PASSWORD");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_ROOT_PASSWORD="$PARAMETER_VALUE";
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "MYSQL_SERVER_DB_NAME");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_DATABASE="$PARAMETER_VALUE";
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "MYSQL_SERVER_USER");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_USER="$PARAMETER_VALUE";
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "MYSQL_SERVER_PASS");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_PASSWORD="$PARAMETER_VALUE";
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "ELASTICSEARCH_SERVER_HOST");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			ELASTICSEARCH_HOST="$PARAMETER_VALUE";
			if [ "$ELASTICSEARCH_HOST" == "$ELASTICSEARCH_CONTAINER_NAME" ]; then
				ELASTICSEARCH_HOST="";
			fi
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "ELASTICSEARCH_SERVER_HTTPPORT");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			ELASTICSEARCH_PORT="$PARAMETER_VALUE";
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$COMMUNITY_CONTAINER_NAME" "MAIL_IMAPSYNC_START_DATE");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MAIL_IMAPSYNC_START_DATE="$PARAMETER_VALUE";
		fi
	fi

	if [[ -n ${MAIL_SERVER_ID} ]]; then
		PARAMETER_VALUE=$(get_container_env_parameter "$MAIL_CONTAINER_NAME" "MYSQL_SERVER");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_HOST="$PARAMETER_VALUE";
			if [ "$MYSQL_HOST" == "$MYSQL_CONTAINER_NAME" ]; then
				MYSQL_HOST="";
			fi
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$MAIL_CONTAINER_NAME" "MYSQL_SERVER_PORT");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_PORT="$PARAMETER_VALUE";
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$MAIL_CONTAINER_NAME" "MYSQL_ROOT_USER");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_ROOT_USER="$PARAMETER_VALUE";
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$MAIL_CONTAINER_NAME" "MYSQL_ROOT_PASSWD");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_ROOT_PASSWORD="$PARAMETER_VALUE";
		fi

		PARAMETER_VALUE=$(get_container_env_parameter "$MAIL_CONTAINER_NAME" "MYSQL_SERVER_DB_NAME");
		if [[ -n ${PARAMETER_VALUE} ]]; then
			MYSQL_MAIL_DATABASE="$PARAMETER_VALUE";
		fi
	fi
}

get_container_env_parameter () {
	CONTAINER_NAME=$1;
	PARAMETER_NAME=$2;
	VALUE="";

	if [[ -z ${CONTAINER_NAME} ]]; then
		echo "Empty container name"
		exit 1;
	fi

	if [[ -z ${PARAMETER_NAME} ]]; then
		echo "Empty parameter name"
		exit 1;
	fi

	if command_exists docker ; then
		CONTAINER_EXIST=$(docker ps -aqf "name=$CONTAINER_NAME");

		if [[ -n ${CONTAINER_EXIST} ]]; then
			VALUE=$(docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' ${CONTAINER_NAME} | grep "${PARAMETER_NAME}=" | sed 's/^.*=//');
		fi
	fi

	echo "$VALUE"
}

move_mail_server_database () {
	EXIST_DATABASE=$(docker exec -i ${MYSQL_CONTAINER_NAME} mysql -s -N -u ${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -e "show databases;" 2>/dev/null | { grep -sw ${MYSQL_MAIL_DATABASE} || true; });
	EXIST_MAIL_DATABASE=$(docker exec -itd ${MAIL_CONTAINER_NAME} mysql -s -N -u ${MYSQL_ROOT_USER} -p${MYSQL_MAIL_ROOT_PASSWORD} -e "show databases;" 2>/dev/null | { grep -sw ${MYSQL_MAIL_DATABASE} || true; })
	if [[ -n ${EXIST_DATABASE} ]]; then
		echo "$MYSQL_MAIL_DATABASE database already exist in $MYSQL_CONTAINER_NAME"
	elif [[ -z "${EXIST_MAIL_DATABASE}" ]]; then
		echo "$MYSQL_MAIL_DATABASE database does not exist in $MAIL_CONTAINER_NAME"
	else
		if ! docker exec -itd ${MAIL_CONTAINER_NAME} mysqladmin -u ${MYSQL_ROOT_USER} -p${MYSQL_MAIL_ROOT_PASSWORD} status; then
			echo "$MAIL_CONTAINER_NAME mysqld service not available."
			exit 1;
		fi
		echo "creating $MYSQL_MAIL_DATABASE database dump file"
		if ! docker exec -it ${MAIL_CONTAINER_NAME} mysqldump -u ${MYSQL_ROOT_USER} -p${MYSQL_MAIL_ROOT_PASSWORD} ${MYSQL_MAIL_DATABASE} > dump.sql; then
			echo "$MAIL_CONTAINER_NAME could not create $MYSQL_MAIL_DATABASE database dump file"
			exit 1;
		fi
		if ! docker exec -i ${MYSQL_CONTAINER_NAME} mysql -u ${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE \`${MYSQL_MAIL_DATABASE}\`"; then
			echo "$MYSQL_CONTAINER_NAME could not create $MYSQL_MAIL_DATABASE database"
			exit 1;
		fi
		echo "restoring $MYSQL_MAIL_DATABASE database dump file"
		if ! docker exec -i ${MYSQL_CONTAINER_NAME} mysql -u ${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} ${MYSQL_MAIL_DATABASE} < dump.sql; then
			echo "$MYSQL_CONTAINER_NAME could not restore $MYSQL_MAIL_DATABASE database dump file"
			exit 1;
		fi

		rm -f dump.sql
	fi
}

stop_mail_server_mysql () {
	if ! docker exec -it ${MAIL_CONTAINER_NAME} service mysqld stop; then
		echo "$MAIL_CONTAINER_NAME mysqld service could not be stopped correctly."
	fi
}

stop_community_server_mysql () {
	if ! docker exec -it ${COMMUNITY_CONTAINER_NAME} service god stop; then
			echo "$COMMUNITY_CONTAINER_NAME god service could not be stopped correctly."
	fi
	if ! docker exec -it ${COMMUNITY_CONTAINER_NAME} service mysql stop; then
		echo "$COMMUNITY_CONTAINER_NAME mysql service could not be stopped correctly."
	fi
}

remove_container () {
	CONTAINER_NAME=$1;

	if [[ -z ${CONTAINER_NAME} ]]; then
		echo "Empty container name"
		exit 1;
	fi

	echo "stop container:"
	docker stop ${CONTAINER_NAME};
	echo "remove container:"
	docker rm -f ${CONTAINER_NAME};

	sleep 10 #Hack for SuSe: exception "Error response from daemon: devmapper: Unknown device xxx"

	echo "check removed container: $CONTAINER_NAME"
	CONTAINER_ID=$(get_container_id "$CONTAINER_NAME");

	if [[ -n ${CONTAINER_ID} ]]; then
		echo "try again remove ${CONTAINER_NAME}"
		remove_container ${CONTAINER_NAME}
	fi
}

pull_mysql_server () {
	if file_exists ${BASE_DIR}/mysql/.private/$MYSQL_DATABASE.version; then
		MYSQL_VERSION=$(cat ${BASE_DIR}/mysql/.private/$MYSQL_DATABASE.version)	
	elif grep "Version:" ${BASE_DIR}/mysql/logs/error.log > /dev/null 2>&1 ; then
		MYSQL_VERSION=$(grep "Version:" ${BASE_DIR}/mysql/logs/error.log | grep -Po "'[0-99].[0-99]..*?'" | head -1 | tr -d \')
	fi

	echo $MYSQL_VERSION > ${BASE_DIR}/mysql/.private/$MYSQL_DATABASE.version

	if file_exists "${MYSQL_IMAGE_NAME}"; then
		docker load -i ${MYSQL_IMAGE_NAME}

		FILE_NAME=$(basename $MYSQL_IMAGE_NAME)
		TMP_STRING=${FILE_NAME//.tar.gz/ }
		TMP_ARRAY=(${TMP_STRING//_/ })
		MYSQL_IMAGE_NAME=${TMP_ARRAY[0]/-//}
		MYSQL_VERSION="${TMP_ARRAY[1]}"
	else
		if [[ -z ${MYSQL_VERSION} ]]; then
			MYSQL_VERSION=$(get_available_version "$MYSQL_IMAGE_NAME");
		fi

		pull_image ${MYSQL_IMAGE_NAME} ${MYSQL_VERSION}
	fi
}

pull_document_server () {
	if file_exists "${DOCUMENT_IMAGE_NAME}"; then
		docker load -i ${DOCUMENT_IMAGE_NAME}

		FILE_NAME=$(basename $DOCUMENT_IMAGE_NAME)
		TMP_STRING=${FILE_NAME//.tar.gz/ }
		TMP_ARRAY=(${TMP_STRING//-/ })
		DOCUMENT_IMAGE_NAME="${TMP_ARRAY[0]}/${TMP_ARRAY[1]}"
		DOCUMENT_VERSION="${TMP_ARRAY[2]}"
	else
		if [[ -z ${DOCUMENT_VERSION} ]]; then
			DOCUMENT_VERSION=$(get_available_version "$DOCUMENT_IMAGE_NAME");
		fi

		pull_image ${DOCUMENT_IMAGE_NAME} ${DOCUMENT_VERSION}
	fi
}

pull_mail_server () {
	if file_exists "${MAIL_IMAGE_NAME}"; then
		docker load -i ${MAIL_IMAGE_NAME}

		FILE_NAME=$(basename $MAIL_IMAGE_NAME)
		TMP_STRING=${FILE_NAME//.tar.gz/ }
		TMP_ARRAY=(${TMP_STRING//-/ })
		MAIL_IMAGE_NAME="${TMP_ARRAY[0]}/${TMP_ARRAY[1]}"
		MAIL_VERSION="${TMP_ARRAY[2]}"
	else
		if [[ -z ${MAIL_VERSION} ]]; then
			MAIL_VERSION=$(get_available_version "$MAIL_IMAGE_NAME");
		fi

		pull_image ${MAIL_IMAGE_NAME} ${MAIL_VERSION}
	fi
}

pull_elasticsearch () {
	if file_exists "${ELASTICSEARCH_IMAGE_NAME}"; then
		docker load -i ${ELASTICSEARCH_IMAGE_NAME}

		FILE_NAME=$(basename $ELASTICSEARCH_IMAGE_NAME)
		TMP_STRING=${FILE_NAME//.tar.gz/ }
		TMP_ARRAY=(${TMP_STRING//-/ })
		ELASTICSEARCH_IMAGE_NAME="${TMP_ARRAY[0]}/${TMP_ARRAY[1]}"
		ELASTICSEARCH_VERSION="${TMP_ARRAY[2]}"
	else
		if [[ -z ${ELASTICSEARCH_VERSION} ]]; then
			ELASTICSEARCH_VERSION=$(get_available_version "$ELASTICSEARCH_IMAGE_NAME");
		fi

		pull_image ${ELASTICSEARCH_IMAGE_NAME} ${ELASTICSEARCH_VERSION}
	fi
}

pull_controlpanel () {
	if file_exists "${CONTROLPANEL_IMAGE_NAME}"; then
		docker load -i ${CONTROLPANEL_IMAGE_NAME}

		FILE_NAME=$(basename $CONTROLPANEL_IMAGE_NAME)
		TMP_STRING=${FILE_NAME//.tar.gz/ }
		TMP_ARRAY=(${TMP_STRING//-/ })
		CONTROLPANEL_IMAGE_NAME="${TMP_ARRAY[0]}/${TMP_ARRAY[1]}"
		CONTROLPANEL_VERSION="${TMP_ARRAY[2]}"
	else
		if [[ -z ${CONTROLPANEL_VERSION} ]]; then
			CONTROLPANEL_VERSION=$(get_available_version "$CONTROLPANEL_IMAGE_NAME");
		fi

		pull_image ${CONTROLPANEL_IMAGE_NAME} ${CONTROLPANEL_VERSION}
	fi
}

pull_community_server () {
	if file_exists "${COMMUNITY_IMAGE_NAME}"; then
		docker load -i ${COMMUNITY_IMAGE_NAME}

		FILE_NAME=$(basename $COMMUNITY_IMAGE_NAME)
		TMP_STRING=${FILE_NAME//.tar.gz/ }
		TMP_ARRAY=(${TMP_STRING//_/ })
		COMMUNITY_IMAGE_NAME=${TMP_ARRAY[0]/-//}
		COMMUNITY_VERSION="${TMP_ARRAY[1]}"
	else
		if [[ -z ${COMMUNITY_VERSION} ]]; then
			COMMUNITY_VERSION=$(get_available_version "$COMMUNITY_IMAGE_NAME");
		fi

		pull_image ${COMMUNITY_IMAGE_NAME} ${COMMUNITY_VERSION}
	fi
}

pull_image () {
	IMAGE_NAME=$1;
	IMAGE_VERSION=$2;

	if [[ -z ${IMAGE_NAME} || -z ${IMAGE_VERSION} ]]; then
		echo "Docker pull argument exception: repository=$IMAGE_NAME, tag=$IMAGE_VERSION"
		exit 1;
	fi

	EXIST=$(docker images --format "{{.Repository}}:{{.Tag}}" | { grep -x "${IMAGE_NAME}:${IMAGE_VERSION}" || true; });
	COUNT=1;

	while [[ -z $EXIST && $COUNT -le 3 ]]; do
		docker pull ${IMAGE_NAME}:${IMAGE_VERSION}
		EXIST=$(docker images --format "{{.Repository}}:{{.Tag}}" | { grep -x "${IMAGE_NAME}:${IMAGE_VERSION}" || true; });
		(( COUNT++ ))
	done

	if [[ -z $EXIST ]]; then
		echo "Docker image $IMAGE_NAME:$IMAGE_VERSION not found"
		exit 1;
	fi
}

set_partner_data () {
	if [[ -n ${PARTNER_DATA_FILE} ]]; then
		curl -o ${BASE_DIR}/CommunityServer/data/json-data.txt ${PARTNER_DATA_FILE}
	fi
}

create_network () {
	EXIST=$(docker network ls | awk '{print $2;}' | { grep -x ${NETWORK} || true; });

	if [[ -z ${EXIST} ]]; then
		docker network create --driver bridge ${NETWORK}
	fi
}

set_installation_type_data () {
	if [ "$INSTALLATION_TYPE" == "GROUPS" ]; then
		INSTALL_DOCUMENT_SERVER="false";
		INSTALL_MAIL_SERVER="false";
		set_opensource_data
	elif [ "$INSTALLATION_TYPE" == "WORKSPACE" ]; then
		set_opensource_data
	fi
}

set_opensource_data () {
	COMMUNITY_IMAGE_NAME="onlyoffice/communityserver";
	DOCUMENT_IMAGE_NAME="onlyoffice/documentserver";
	MAIL_IMAGE_NAME="onlyoffice/mailserver";
	CONTROLPANEL_IMAGE_NAME="onlyoffice/controlpanel";

	HUB="";
	USERNAME="";
	PASSWORD="";
}

ping_host_port () {
	HOST=$1
	PORT=$2

	if [ -z "$HOST" ] || [ -z "$PORT" ]; then
		echo "mysql host or port is empty"
		exit 1;
	fi

	if command_exists nc ; then
		RESULT=`nc -z -v -w5 $HOST $PORT &> /dev/null; echo $?`
		if [ $RESULT != 0 ]; then
			echo "Error ping $HOST:$PORT"
			exit 1;
		fi
	fi
}

check_domain () {
	if ! command_exists dig ; then
		if command_exists apt-get; then
			apt-get -y update
			apt-get install -y dnsutils
		elif command_exists yum; then
			yum install bind-utils
		fi

		if ! command_exists dig; then
			echo "command dig not found"
			exit 1;
		fi

		if ! command_exists host; then
			echo "command host not found"
			exit 1;
		fi
	fi

	IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
	RESULT=$(host $MAIL_DOMAIN_NAME | { grep $IP || true; })

	if [[ -z $IP ]]; then
		echo "Could not determine the external ip of the current server";
		RESULT=true;
	elif [[ -z ${RESULT} ]]; then
		echo "$MAIL_DOMAIN_NAME is not linked to the $IP address. Please check your A-record."
		exit 1;
	fi
}

check_vsyscall () {
	MIN_NUM_ARR=(4 18 0);
	CUR_NUM_ARR=();

	CUR_STR_ARR=$(echo $KERNEL | grep -Po "[0-9]+\.[0-9]+\.[0-9]+" | tr "." " ");
	for CUR_STR_ITEM in $CUR_STR_ARR
	do
		CUR_NUM_ARR=(${CUR_NUM_ARR[@]} $CUR_STR_ITEM)
	done

	INDEX=0;
	NEED_VSYSCALL_CHECK="true";

	while [[ $INDEX -lt 3 ]]; do
		if [ ${CUR_NUM_ARR[INDEX]} -lt ${MIN_NUM_ARR[INDEX]} ]; then
			NEED_VSYSCALL_CHECK="false";
			INDEX=3;
		elif [ ${CUR_NUM_ARR[INDEX]} -gt ${MIN_NUM_ARR[INDEX]} ]; then
			INDEX=3;
		fi
		(( INDEX++ ))
	done

	if [ "$NEED_VSYSCALL_CHECK" == "true" ]; then
		VSYSCALL_ENABLED=$(cat /proc/self/maps | egrep 'vsyscall');
		if [ -z "$VSYSCALL_ENABLED" ]; then
			echo "vsyscall is required for the Mail Server to work correctly"
			echo "Please use this instruction https://helpcenter.onlyoffice.com/server/docker/mail/enabling-vsyscall-on-debian.aspx"
			exit 1;
		fi
	fi
}

start_installation () {
	root_checking

	set_installation_type_data

	set_jwt_enabled
	set_jwt_header
	set_jwt_secret

	set_core_machinekey

	if [ "$UPDATE" == "true" ]; then
		read_parameters
	fi

	get_os_info

	check_os_info

	check_kernel

	if [ "$SKIP_HARDWARE_CHECK" != "true" ]; then
		check_hardware
	fi

	if [ "$UPDATE" != "true" ]; then
		check_ports
		MYSQL_VERSION="8.0.29";

		if [ "$INSTALL_MAIL_SERVER" == "true" ]; then
			if [[ -z ${MAIL_DOMAIN_NAME} ]]; then

				INSTALL_MAIL_SERVER_TEMP="";

				while [ "$INSTALL_MAIL_SERVER_TEMP" != "Y" ] && [ "$INSTALL_MAIL_SERVER_TEMP" != "N" ]; do
					read -p "Install ONLYOFFICE Mail Server [Y/N]?: " INSTALL_MAIL_SERVER_TEMP
					INSTALL_MAIL_SERVER_TEMP="$(echo $INSTALL_MAIL_SERVER_TEMP | tr '[:lower:]' '[:upper:]')";
				done

				if [ "$INSTALL_MAIL_SERVER_TEMP" = "Y" ]; then
					while [ -z "$MAIL_DOMAIN_NAME" ]; do
						read -p "Enter mail domain for ONLYOFFICE Mail Server: " MAIL_DOMAIN_NAME
					done
				fi
			fi

			if [[ -z ${MAIL_DOMAIN_NAME} ]]; then
				INSTALL_MAIL_SERVER="false";
			elif [ "$SKIP_DOMAIN_CHECK" != "true" ]; then
				check_domain
			fi

			if [ "$INSTALL_MAIL_SERVER" == "true" ] && [ "$DIST" == "Debian" ]; then
				check_vsyscall
			fi
		fi
	elif [[ -z $(get_container_id "$MAIL_CONTAINER_NAME") ]]; then
		INSTALL_MAIL_SERVER="false";
	fi

	if [ "$MAKESWAP" == "true" ]; then
		make_swap
	fi

	if command_exists docker ; then
		check_docker_version
		service docker start
	else
		install_docker
	fi

	docker_login

	make_directories

	set_partner_data

	create_network

	if [[ -z ${MYSQL_HOST} ]]; then
		if [ "$INSTALL_MAIL_SERVER" == "true" ] || [ "$INSTALL_COMMUNITY_SERVER" == "true" ]; then
			pull_mysql_server
			install_mysql_server
		elif [ "$INSTALL_MAIL_SERVER" == "pull" ] || [ "$INSTALL_COMMUNITY_SERVER" == "pull" ]; then
			pull_mysql_server
		fi
	else
		ping_host_port "$MYSQL_HOST" "$MYSQL_PORT"
	fi

	if [[ -z ${ELASTICSEARCH_HOST} ]]; then
		if [ "$INSTALL_ELASTICSEARCH" == "true" ]; then
			pull_elasticsearch
			install_elasticsearch
		elif [ "$INSTALL_ELASTICSEARCH" == "pull" ]; then
			pull_elasticsearch
		fi
	else
		ping_host_port "$ELASTICSEARCH_HOST" "$ELASTICSEARCH_PORT"
		ELASTICSEARCH_SERVER="$ELASTICSEARCH_HOST";
	fi

	if [ "$INSTALL_DOCUMENT_SERVER" == "true" ]; then
		pull_document_server
		install_document_server
	elif [ "$INSTALL_DOCUMENT_SERVER" == "pull" ]; then
		pull_document_server
	fi

	if [ "$INSTALL_MAIL_SERVER" == "true" ]; then
		pull_mail_server
		install_mail_server
	elif [ "$INSTALL_MAIL_SERVER" == "pull" ]; then
		pull_mail_server
	fi

	if [ "$INSTALL_CONTROLPANEL" == "true" ]; then
		pull_controlpanel
		install_controlpanel
	elif [ "$INSTALL_CONTROLPANEL" == "pull" ]; then
		pull_controlpanel
	fi

	if [ "$INSTALL_COMMUNITY_SERVER" == "true" ]; then
		pull_community_server
		install_community_server
	elif [ "$INSTALL_COMMUNITY_SERVER" == "pull" ]; then
		pull_community_server
	fi

	[ -n "$JWT_MESSAGE" ] && [ -n "$DOCUMENT_SERVER_ID" ] && JWT_MESSAGE=$(echo "$JWT_MESSAGE" | sed 's/$(sudo docker ps -q)/'"${DOCUMENT_SERVER_ID::12}"'/') && echo -e "\n$JWT_MESSAGE"
	echo ""
	echo "Thank you for installing ONLYOFFICE."
	echo "You can now configure your portal and add Mail Server to your installation (in case you skipped it earlier) using the Control Panel"
	echo "In case you have any questions contact us via http://support.onlyoffice.com or visit our forum at http://forum.onlyoffice.com"
	echo ""

	exit 0;
}

start_installation
