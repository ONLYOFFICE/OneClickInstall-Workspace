#!/bin/bash

set -e

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
