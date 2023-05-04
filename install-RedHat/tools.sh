#!/bin/bash

set -e

function make_swap () {
	local DISK_REQUIREMENTS=6144; #6Gb free space
	local MEMORY_REQUIREMENTS=11000; #RAM ~12Gb

	local AVAILABLE_DISK_SPACE=$(df -m /  | tail -1 | awk '{ print $4 }');
	local TOTAL_MEMORY=$(free -m | grep -oP '\d+' | head -n 1);
	local EXIST=$(swapon -s | awk '{ print $1 }' | { grep -x '/app_swapfile' || true; });

	if [[ -z $EXIST ]] && [ ${TOTAL_MEMORY} -lt ${MEMORY_REQUIREMENTS} ] && [ ${AVAILABLE_DISK_SPACE} -gt ${DISK_REQUIREMENTS} ]; then
		dd if=/dev/zero of=/app_swapfile count=6144 bs=1MiB
		chmod 600 /app_swapfile
		mkswap /app_swapfile
		swapon /app_swapfile
		echo "/app_swapfile none swap sw 0 0" >> /etc/fstab
	fi
}

vercomp () {
    if [[ $1 == $2 ]]
    then
        echo 0
		return
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo 1
			return			
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo 2			
			return
        fi
    done
    echo 0
}

check_hardware () {
    DISK_REQUIREMENTS=40960;
    MEMORY_REQUIREMENTS=5500;
    CORE_REQUIREMENTS=2;

	AVAILABLE_DISK_SPACE=$(df -m /  | tail -1 | awk '{ print $4 }');

	if [ ${AVAILABLE_DISK_SPACE} -lt ${DISK_REQUIREMENTS} ]; then
		echo "Minimal requirements are not met: need at least $DISK_REQUIREMENTS MB of free HDD space"
		exit 1;
	fi

	TOTAL_MEMORY=$(free -m | grep -oP '\d+' | head -n 1);

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

if [ "$SKIP_HARDWARE_CHECK" != "true" ]; then
	check_hardware
fi

read_unsupported_installation () {
	read -p "$RES_CHOICE_INSTALLATION " CHOICE_INSTALLATION
	case "$CHOICE_INSTALLATION" in
		y|Y )
			yum -y install $DIST*-release
		;;

		n|N )
			exit 0;
		;;

		* )
			echo $RES_CHOICE;
			read_unsupported_installation
		;;
	esac
}

read_rabbitmq_update () {
	read -p "$RES_CHOICE_RABBITMQ " CHOICE_INSTALLATION
	case "$CHOICE_INSTALLATION" in
		y|Y )
			rm -rf /var/lib/rabbitmq/mnesia/$(rabbitmqctl eval "node().")
			yum -y remove rabbitmq-server erlang* 
		;;

		n|N )
			rm -f /etc/yum.repos.d/rabbitmq_*
		;;

		* )
			echo $RES_CHOICE;
			read_rabbitmq_update
		;;
	esac
}
