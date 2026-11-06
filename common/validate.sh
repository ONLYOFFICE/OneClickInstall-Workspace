#!/bin/bash

validate_bool() {
	case "$2" in
		true | false ) ;;
		* ) echo "Error: Invalid ${1} '${2}'. Valid values: true, false." >&2; exit 1 ;;
	esac
}

# Validates the arguments shared by the DEB and RPM installers
validate_installer_arguments() {
	case "${INSTALLATION_TYPE}" in
		GROUPS | WORKSPACE | WORKSPACE_ENTERPRISE ) ;;
		* ) echo "Error: Invalid --installationtype '${INSTALLATION_TYPE}'. Valid values: GROUPS, WORKSPACE, WORKSPACE_ENTERPRISE." >&2; exit 1 ;;
	esac

	validate_bool --update "$UPDATE"
	validate_bool --localscripts "$LOCAL_SCRIPTS"
	validate_bool --skiphardwarecheck "$SKIP_HARDWARE_CHECK"
	validate_bool --makeswap "$MAKESWAP"
}
