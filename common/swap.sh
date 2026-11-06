#!/bin/bash

# Creates a swap file; any failure only produces a warning, swap is optional
make_swap () {
	local SWAPFILE="$1"
	local DISK_REQUIREMENTS=6144 #6Gb free space
	local AVAILABLE_DISK_SPACE EXIST

	AVAILABLE_DISK_SPACE=$(df -Pm / | awk 'NR == 2 { print $4 }')
	EXIST=$(swapon -s | awk '{ print $1 }' | { grep -x "${SWAPFILE}" || true; })

	if [ -n "${EXIST}" ]; then
		return 0
	fi

	if [ "${AVAILABLE_DISK_SPACE}" -le "${DISK_REQUIREMENTS}" ]; then
		echo "Warning: swap file was not created, less than ${DISK_REQUIREMENTS} MB of free disk space on /"
		return 0
	fi

	# fallocate may produce a file with holes that swapon rejects, so fall back to dd; status 2 means swapon is not permitted here
	local STATUS=0
	enable_swap_file "${SWAPFILE}" fallocate || STATUS=$?
	if [ "${STATUS}" -eq 1 ]; then
		STATUS=0
		enable_swap_file "${SWAPFILE}" dd || STATUS=$?
	fi
	if [ "${STATUS}" -eq 0 ]; then
		awk -v swapfile="${SWAPFILE}" '$1 == swapfile && $3 == "swap" { found = 1 } END { exit !found }' /etc/fstab || echo "${SWAPFILE} none swap sw 0 0" >> /etc/fstab
		echo "Swap file ${SWAPFILE} (6 GB) was created and enabled"
	else
		rm -f "${SWAPFILE}"
		echo "Warning: swap file was not created, continuing without it"
	fi
	return 0
}

enable_swap_file () {
	local SWAPFILE="$1"
	local METHOD="$2"

	rm -f "${SWAPFILE}" && touch "${SWAPFILE}" || return 1
	[ "$(df -T / | awk 'NR==2{print $2}')" != "btrfs" ] || chattr +C "${SWAPFILE}" || return 1

	if [ "${METHOD}" = "fallocate" ]; then
		fallocate -l 6G "${SWAPFILE}"
	else
		dd if=/dev/zero of="${SWAPFILE}" bs=1MiB count=6144 status=none
	fi || return 1

	chmod 600 "${SWAPFILE}" && mkswap "${SWAPFILE}" >/dev/null || return 1

	local SWAPON_ERROR
	SWAPON_ERROR=$(swapon "${SWAPFILE}" 2>&1) && return 0
	[[ "${SWAPON_ERROR}" == *"not permitted"* ]] && return 2
	return 1
}

# Creates the swap file only on hosts with less than 16 GB of RAM
make_swap_on_low_memory () {
	local MEMORY_REQUIREMENTS=16000 #RAM ~16Gb
	local TOTAL_MEMORY

	TOTAL_MEMORY=$(free --mega | awk '/^Mem:/ { print $2 }')

	if [ "${TOTAL_MEMORY}" -lt "${MEMORY_REQUIREMENTS}" ]; then
		make_swap "$1"
	fi
	return 0
}
