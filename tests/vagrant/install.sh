#!/bin/bash

set -e 

while [ "$1" != "" ]; do
	case $1 in

		-ds | --download-scripts )
                        if [ "$2" != "" ]; then
                                DOWNLOAD_SCRIPTS=$2
                                shift
                        fi
                ;;

                -arg | --arguments )
                        if [ "$2" != "" ]; then
                                ARGUMENTS=$2
                                shift
                        fi
                ;;


	        -pi | --production-install )
			if [ "$2" != "" ]; then
				PRODUCTION_INSTALL=$2
				shift
			fi
		;;

		-li | --local-install )
                        if [ "$2" != "" ]; then
                                LOCAL_INSTALL=$2
                                shift
                        fi
                ;;

		-lu | --local-update )
                        if [ "$2" != "" ]; then
                                LOCAL_UPDATE=$2
                                shift
                        fi
                ;;

	        -tr | --test-repo )
			if [ "$2" != "" ]; then
				TEST_REPO_ENABLE=$2
				shift
		        fi
		;;


        esac
	shift
done

export TERM=xterm-256color^M

SERVICES_SYSTEMD=(
	"monoserve.service"
	"monoserveApiSystem.service"
	"onlyofficeFilesTrashCleaner.service" 
	"onlyofficeBackup.service" 
	"onlyofficeControlPanel.service" 
	"onlyofficeFeed.service" 
	"onlyofficeIndex.service"                          
        "onlyofficeJabber.service"                         
        "onlyofficeMailAggregator.service"                 
        "onlyofficeMailCleaner.service"                    
        "onlyofficeMailImap.service"                       
        "onlyofficeMailWatchdog.service"                  
        "onlyofficeNotify.service"                   
        "onlyofficeRadicale.service"                       
        "onlyofficeSocketIO.service"                       
        "onlyofficeSsoAuth.service"                        
        "onlyofficeStorageEncryption.service"              
        "onlyofficeStorageMigrate.service"                
        "onlyofficeTelegram.service"                       
        "onlyofficeThumb.service"                        
        "onlyofficeThumbnailBuilder.service"               
        "onlyofficeUrlShortener.service"                   
        "onlyofficeWebDav.service"
        "ds-converter.service"
        "ds-docservice.service"
        "ds-metrics.service")      

function common::get_colors() {
    COLOR_BLUE=$'\e[34m'
    COLOR_GREEN=$'\e[32m'
    COLOR_RED=$'\e[31m'
    COLOR_RESET=$'\e[0m'
    COLOR_YELLOW=$'\e[33m'
    export COLOR_BLUE
    export COLOR_GREEN
    export COLOR_RED
    export COLOR_RESET
    export COLOR_YELLOW
}

#############################################################################################
# Checking available resources for a virtual machine
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#############################################################################################
function check_hw() {
        local FREE_RAM=$(free -h)
	local FREE_CPU=$(nproc)
	echo "${COLOR_RED} ${FREE_RAM} ${COLOR_RESET}"
        echo "${COLOR_RED} ${FREE_CPU} ${COLOR_RESET}"
}


#############################################################################################
# Prepare vagrant boxes like: set hostname/remove postfix for DEB distributions
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   ☑ PREPAVE_VM: **<prepare_message>**
#############################################################################################
function prepare_vm() {

  if [ -f /etc/lsb-release ] ; then
        DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
        REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
        DISTRIB_CODENAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
        DISTRIB_RELEASE=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
  elif [ -f /etc/lsb_release ] || [ -f /usr/bin/lsb_release ] ; then
        DIST=`lsb_release -a 2>&1 | grep 'Distributor ID:' | awk -F ":" '{print $2 }'`
        REV=`lsb_release -a 2>&1 | grep 'Release:' | awk -F ":" '{print $2 }'`
        DISTRIB_CODENAME=`lsb_release -a 2>&1 | grep 'Codename:' | awk -F ":" '{print $2 }'`
        DISTRIB_RELEASE=`lsb_release -a 2>&1 | grep 'Release:' | awk -F ":" '{print $2 }'`
  elif [ -f /etc/os-release ] ; then
        DISTRIB_CODENAME=$(grep "VERSION=" /etc/os-release |awk -F= {' print $2'}|sed s/\"//g |sed s/[0-9]//g | sed s/\)$//g |sed s/\(//g | tr -d '[:space:]')
        DISTRIB_RELEASE=$(grep "VERSION_ID=" /etc/os-release |awk -F= {' print $2'}|sed s/\"//g |sed s/[0-9]//g | sed s/\)$//g |sed s/\(//g | tr -d '[:space:]')
  fi

  DIST=`echo "$DIST" | tr '[:upper:]' '[:lower:]' | xargs`;
  DISTRIB_CODENAME=`echo "$DISTRIB_CODENAME" | tr '[:upper:]' '[:lower:]' | xargs`;
  REV=`echo "$REV" | xargs`;

  if [ ! -f /etc/centos-release ]; then
	if [ "${DIST}" = "debian" ]; then
	     if [ "${DISTRIB_CODENAME}" == "bookworm" ]; then
		     apt-get update -y
		     apt install -y curl gnupg
             fi

             systemctl stop postfix
	     systemctl disable postfix
	     apt-get remove postfix -y
             echo "${COLOR_GREEN}☑ PREPAVE_VM: Postfix was removed${COLOR_RESET}"
        fi

	if [ "${TEST_REPO_ENABLE}" == 'true' ]; then
   	   mkdir -p -m 700 $HOME/.gnupg
  	   echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] http://static.teamlab.info.s3.amazonaws.com/repo/4testing/debian stable main" | tee /etc/apt/sources.list.d/onlyoffice4testing.list
  	   curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/onlyoffice.gpg --import
  	   chmod 644 /usr/share/keyrings/onlyoffice.gpg
	fi
  fi

  if [ -f /etc/centos-release ]; then
	  if [ "${TEST_REPO_ENABLE}" == 'true' ]; then
	  cat > /etc/yum.repos.d/onlyoffice4testing.repo <<END
[onlyoffice4testing]
name=onlyoffice4testing repo
baseurl=http://static.teamlab.info.s3.amazonaws.com/repo/4testing/centos/main/noarch/
gpgcheck=1
gpgkey=https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE
enabled=1
END
          yum -y install centos*-release
	  fi

	  local REV=$(cat /etc/redhat-release | sed 's/[^0-9.]*//g')
	  if [[ "${REV}" =~ ^9 ]]; then
		  update-crypto-policies --set LEGACY
		  echo "${COLOR_GREEN}☑ PREPAVE_VM: sha1 gpg key chek enabled${COLOR_RESET}"
	  fi
  fi

  # Clean up home folder
  rm -rf /home/vagrant/*

  if [ -d /tmp/workspace ]; then
          mv /tmp/workspace/* /home/vagrant
  fi

  echo '127.0.0.1 host4test' | sudo tee -a /etc/hosts   
  echo "${COLOR_GREEN}☑ PREPAVE_VM: Hostname was setting up${COLOR_RESET}"   

}

#############################################################################################
# Install workspace and then healthcheck
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Script log
#############################################################################################
function install_workspace() {
	if [ "${DOWNLOAD_SCRIPTS}" == 'true' ]; then
            wget https://download.onlyoffice.com/install/workspace-install.sh
  else
    sed 's/set -e/set -xe/' -i *.sh
  fi

	printf "N\nY\nY" | bash workspace-install.sh ${ARGUMENTS}

	if [[ $? != 0 ]]; then
	    echo "Exit code non-zero. Exit with 1."
	    exit 1
	else
	    echo "Exit code 0. Continue..."
	fi
}

#############################################################################################
# Healthcheck function for systemd services
# Globals:
#   SERVICES_SYSTEMD
# Arguments:
#   None
# Outputs:
#   Message about service status 
#############################################################################################
function healthcheck_systemd_services() {
  for service in ${SERVICES_SYSTEMD[@]} 
  do 
    if systemctl is-active --quiet ${service}; then
      echo "${COLOR_GREEN}☑ OK: Service ${service} is running${COLOR_RESET}"
    else 
      echo "${COLOR_RED}⚠ FAILED: Service ${service} is not running${COLOR_RESET}"
      SYSTEMD_SVC_FAILED="true"
    fi
  done
}

#############################################################################################
# Set output if some services failed
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   ⚠ ⚠  ATTENTION: Some sevices is not running ⚠ ⚠ 
# Returns
# 0 if all services is start correctly, non-zero if some failed
#############################################################################################
function healthcheck_general_status() {
  if [ ! -z "${SYSTEMD_SVC_FAILED}" ]; then
    echo "${COLOR_YELLOW}⚠ ⚠  ATTENTION: Some sevices is not running ⚠ ⚠ ${COLOR_RESET}"
    exit 1
  fi
}

#############################################################################################
# Get logs for all services
# Globals:
#   $SERVICES_SYSTEMD
# Arguments:
#   None
# Outputs:
#   Logs for systemd services
# Returns:
#   none
# Commentaries:
# This function succeeds even if the file for cat was not found. For that use ${SKIP_EXIT} variable
#############################################################################################
function services_logs() {
  for service in ${SERVICES_SYSTEMD[@]}; do
    echo -----------------------------------------
    echo "${COLOR_GREEN}Check logs for systemd service: $service${COLOR_RESET}"
    echo -----------------------------------------
    EXIT_CODE=0
    journalctl -u $service || true
  done
  
  local MAIN_LOGS_DIR="/var/log/onlyoffice"
  local DOCS_LOGS_DIR="${MAIN_LOGS_DIR}/documentserver"
  local DOCSERVICE_LOGS_DIR="${DOCS_LOGS_DIR}/docservice"
  local CONVERTER_LOGS_DIR="${DOCS_LOGS_DIR}/converter"
  local METRICS_LOGS_DIR="${DOCS_LOGS_DIR}/metrics"
       
  ARRAY_MAIN_SERVICES_LOGS=($(ls ${MAIN_LOGS_DIR} | grep log | sed 's/web.sql.log//;s/web.api.log//;s/nginx.*//' ))
  ARRAY_DOCSERVICE_LOGS=($(ls ${DOCSERVICE_LOGS_DIR}))
  ARRAY_CONVERTER_LOGS=($(ls ${CONVERTER_LOGS_DIR}))
  ARRAY_METRICS_LOGS=($(ls ${METRICS_LOGS_DIR}))
  
  echo             "-----------------------------------"
  echo "${COLOR_YELLOW} Check logs for main services ${COLOR_RESET}"
  echo             "-----------------------------------"
  for file in ${ARRAY_MAIN_SERVICES_LOGS[@]}; do
    echo ---------------------------------------
    echo "${COLOR_GREEN}logs from file: ${file}${COLOR_RESET}"
    echo ---------------------------------------
    cat ${MAIN_LOGS_DIR}/${file} || true
  done
  
  echo             "-----------------------------------"
  echo "${COLOR_YELLOW} Check logs for Docservice ${COLOR_RESET}"
  echo             "-----------------------------------"
  for file in ${ARRAY_DOCSERVICE_LOGS[@]}; do
    echo ---------------------------------------
    echo "${COLOR_GREEN}logs from file: ${file}${COLOR_RESET}"
    echo ---------------------------------------
    cat ${DOCSERVICE_LOGS_DIR}/${file} || true
  done
  
  echo             "-----------------------------------"
  echo "${COLOR_YELLOW} Check logs for Converter ${COLOR_RESET}"
  echo             "-----------------------------------"
  for file in ${ARRAY_CONVERTER_LOGS[@]}; do
    echo ---------------------------------------
    echo "${COLOR_GREEN}logs from file ${file}${COLOR_RESET}"
    echo ---------------------------------------
    cat ${CONVERTER_LOGS_DIR}/${file} || true
  done
  
  echo             "-----------------------------------"
  echo "${COLOR_YELLOW} Start logs for Metrics ${COLOR_RESET}"
  echo             "-----------------------------------"
  for file in ${ARRAY_METRICS_LOGS[@]}; do
    echo ---------------------------------------
    echo "${COLOR_GREEN}logs from file ${file}${COLOR_RESET}"
    echo ---------------------------------------
    cat ${METRICS_LOGS_DIR}/${file} || true
  done
}

function healthcheck_docker_installation() {
	exit 0
}

main() {
  common::get_colors
  prepare_vm
  check_hw
  install_workspace
  sleep 120
  services_logs
  healthcheck_systemd_services
  healthcheck_general_status
}

main
