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
	TOTAL_MEMORY=$(free --mega | grep -oP '\d+' | head -n 1);
	CPU_CORES_NUMBER=$(cat /proc/cpuinfo | grep processor | wc -l);

	REQUIREMENTS_NOT_MET="";

	if [ ${AVAILABLE_DISK_SPACE} -lt ${DISK_REQUIREMENTS} ]; then
		REQUIREMENTS_NOT_MET="${REQUIREMENTS_NOT_MET}\n  - at least $DISK_REQUIREMENTS MB of free HDD space (available: ${AVAILABLE_DISK_SPACE} MB)";
	fi

	if [ ${TOTAL_MEMORY} -lt ${MEMORY_REQUIREMENTS} ]; then
		REQUIREMENTS_NOT_MET="${REQUIREMENTS_NOT_MET}\n  - at least $MEMORY_REQUIREMENTS MB of RAM (available: ${TOTAL_MEMORY} MB)";
	fi

	if [ ${CPU_CORES_NUMBER} -lt ${CORE_REQUIREMENTS} ]; then
		REQUIREMENTS_NOT_MET="${REQUIREMENTS_NOT_MET}\n  - a CPU with at least $CORE_REQUIREMENTS cores (available: ${CPU_CORES_NUMBER})";
	fi

	if [ -n "${REQUIREMENTS_NOT_MET}" ]; then
		printf "Minimal requirements are not met, your system needs:%b\n\nTo skip this check, use the --skiphardwarecheck true parameter\n" "${REQUIREMENTS_NOT_MET}";
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
