#!/bin/bash

set -e

function make_swap () {
	local DISK_REQUIREMENTS=6144; #6Gb free space
	local MEMORY_REQUIREMENTS=16000; #RAM ~16Gb

	local AVAILABLE_DISK_SPACE=$(df -m /  | tail -1 | awk '{ print $4 }');
	local TOTAL_MEMORY=$(free --mega | grep -oP '\d+' | head -n 1);
	local EXIST=$(swapon -s | awk '{ print $1 }' | { grep -x '/app_swapfile' || true; });

	if [[ -z $EXIST ]] && [ ${TOTAL_MEMORY} -lt ${MEMORY_REQUIREMENTS} ] && [ ${AVAILABLE_DISK_SPACE} -gt ${DISK_REQUIREMENTS} ]; then
		dd if=/dev/zero of=/app_swapfile count=6144 bs=1MiB
		chmod 600 /app_swapfile
		mkswap /app_swapfile
		swapon /app_swapfile
		echo "/app_swapfile none swap sw 0 0" >> /etc/fstab
	fi
}

check_hardware () {
    DISK_REQUIREMENTS=40960;
    MEMORY_REQUIREMENTS=8000;
    CORE_REQUIREMENTS=4;

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

if [ "$SKIP_HARDWARE_CHECK" != "true" ]; then
	check_hardware
fi

read_continue_installation () {
	read -p "$RES_CHOICE_INSTALLATION " CHOICE_INSTALLATION
	case "$CHOICE_INSTALLATION" in
		y|Y )
			return 0
		;;

		n|N )
			return 1
		;;

		* )
			echo $RES_CHOICE;
			read_continue_installation
		;;
	esac
}
