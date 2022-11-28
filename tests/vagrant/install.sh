#!/bin/bash

set -e 

while [ "$1" != "" ]; do
	case $1 in

		-d | --docker_installation )
			if [ "$2" != "" ]; then
				DOCKER_INSTALLATION=$2
				shift
			fi
		;;

	        -p | --production_test )
			if [ "$2" != "" ]; then
				PRODUCTION_TEST=$2
				shift
			fi
		;;

		-l | --local_test )
                        if [ "$2" != "" ]; then
                                LOCAL_TEST=$2
                                shift
                        fi
                ;;

		-u | --update_test )
                        if [ "$2" != "" ]; then
                                UPDATE_TEST=$2
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
	"onlyofficeAutoCleanUp.service" 
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
	"onlyofficeWebDav.service")      

SERVICES_SUPERVISOR=(
	"ds:converter"
	"ds:docservice"
	"ds:metrics")

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
  if [ ! -f /etc/centos-release ]; then 
  	apt-get remove postfix -y 
  	echo "${COLOR_GREEN}☑ PREPAVE_VM: Postfix was removed${COLOR_RESET}"
  fi

  if [ -f /etc/centos-release ]; then
	  local REV=$(cat /etc/redhat-release | sed 's/[^0-9.]*//g')
	  if [[ "${REV}" =~ ^9 ]]; then
		  update-crypto-policies --set LEGACY
		  echo "${COLOR_GREEN}☑ PREPAVE_VM: sha1 gpg key chek enabled${COLOR_RESET}"
	  fi
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
  wget https://download.onlyoffice.com/install/workspace-install.sh 
  bash workspace-install.sh --skiphardwarecheck true --makeswap false <<< "N
  "
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
# Healthcheck function for supervisor services 
# Globals:
#   SERVICES_SUPERVISOR
# Arguments:
#   None
# Outputs:
#   Message about service status 
#############################################################################################
function healthcheck_supervisor_services() {
  for service in ${SERVICES_SUPERVISOR[@]}
    do
      if supervisorctl status ${service} > /dev/null 2>&1 ; then
        echo "${COLOR_GREEN}☑ OK: Service ${service} is running${COLOR_RESET}"
      else
        echo "${COLOR_RED}⚠ FAILED: Service ${service} is not running${COLOR_RESET}"
        SUPERVISOR_SVC_FAILED="true"
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
  if [ ! -z "${SYSTEMD_SVC_FAILED}" ] || [ ! -z "${SUPERVISOR_SVC_FAILED}" ]; then
    echo "${COLOR_YELLOW}⚠ ⚠  ATTENTION: Some sevices is not running ⚠ ⚠ ${COLOR_RESET}"
    exit 1
  fi
}


function healthcheck_docker_installation() {
	exit 0
}

main() {
  common::get_colors
  prepare_vm
  check_hw
  install_workspace
  healthcheck_systemd_services
  healthcheck_supervisor_services
  healthcheck_general_status
}

main
