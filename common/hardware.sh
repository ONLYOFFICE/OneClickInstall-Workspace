#!/bin/bash

check_hardware () {
	local DISK_REQUIREMENTS=40960
	local MEMORY_REQUIREMENTS=8000
	local CORE_REQUIREMENTS=4

	AVAILABLE_DISK_SPACE=$(df -Pm / | awk 'NR == 2 { print $4 }')
	TOTAL_MEMORY=$(free --mega | awk '/^Mem:/ { print $2 }')
	CPU_CORES_NUMBER=$(nproc --all)

	local requirements_not_met=""

	if (( AVAILABLE_DISK_SPACE < DISK_REQUIREMENTS )); then
		requirements_not_met="${requirements_not_met}\n  - at least ${DISK_REQUIREMENTS} MB of free disk space (available: ${AVAILABLE_DISK_SPACE} MB)"
	fi

	if (( TOTAL_MEMORY < MEMORY_REQUIREMENTS )); then
		requirements_not_met="${requirements_not_met}\n  - at least ${MEMORY_REQUIREMENTS} MB of RAM (available: ${TOTAL_MEMORY} MB)"
	fi

	if (( CPU_CORES_NUMBER < CORE_REQUIREMENTS )); then
		requirements_not_met="${requirements_not_met}\n  - a CPU with at least ${CORE_REQUIREMENTS} cores (available: ${CPU_CORES_NUMBER})"
	fi

	if [ -n "${requirements_not_met}" ]; then
		printf "Minimal requirements are not met, your system needs:%b\n\n" "${requirements_not_met}"

		# Without a terminal or in non-interactive mode there is nobody to ask
		if [ "${NON_INTERACTIVE:-false}" = "true" ] || [ ! -t 0 ]; then
			echo "To skip this check, use the --skiphardwarecheck true parameter"
			exit 1
		fi

		read -r -p "Continue installation anyway? (y/N): " CONTINUE_CHOICE
		[[ "${CONTINUE_CHOICE,,}" =~ ^(y|yes)$ ]] || exit 1
	fi
}
