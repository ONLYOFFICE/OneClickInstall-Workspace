#!/bin/bash

set -e

cat<<EOF

#######################################
#  CHECK PORTS
#######################################

EOF

# Prints the installed package matching a name or glob on DEB, or a name or provided capability on RPM
dependency_installed() {
	local MATCHED
	if command -v dpkg-query >/dev/null 2>&1; then
		MATCHED=$(dpkg-query -W -f='${Package} ${db:Status-Status}\n' "$1" 2>/dev/null | awk '$2 == "installed" { print $1; exit }')
	else
		MATCHED=$(rpm -q --whatprovides --qf '%{NAME}\n' "$1" 2>/dev/null) || return 1
		MATCHED=${MATCHED%%$'\n'*}
	fi
	[ -n "${MATCHED}" ] && echo "${MATCHED}"
}

package_installed() {
	if command -v dpkg-query >/dev/null 2>&1; then
		[ "$(dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null)" = "installed" ]
	else
		rpm -q "$1" >/dev/null 2>&1
	fi
}

# Prints the requested TCP ports that already have a listener, comma separated
get_used_ports() {
	ss -H -lnt | awk -v ports="$*" '
		BEGIN { count = split(ports, required, " ") }
		{ sub(/^.*:/, "", $4); busy[$4] = 1 }
		END {
			for (index_port = 1; index_port <= count; index_port++)
				if (required[index_port] in busy) { printf "%s%s", separator, required[index_port]; separator = ", " }
		}'
}

# Sets <variable> to true when one of the packages is installed, otherwise requires the ports to be free
check_component() {
	local VARIABLE="$1" PORTS="$2" COMPONENT_NAME="$3" PACKAGE_NAME USED_PORTS
	shift 2

	for PACKAGE_NAME in "$@"; do
		if package_installed "${PACKAGE_NAME}"; then
			echo "${PACKAGE_NAME} $RES_APP_INSTALLED"
			printf -v "${VARIABLE}" '%s' true
			return 0
		fi
	done
	printf -v "${VARIABLE}" '%s' false

	[ "${UPDATE}" != "true" ] || return 0

	# shellcheck disable=SC2086 # Word splitting of the port list is intended.
	USED_PORTS=$(get_used_ports ${PORTS})
	if [ -n "${USED_PORTS}" ]; then
		echo "${COMPONENT_NAME} $RES_APP_CHECK_PORTS: ${USED_PORTS}"
		echo "$RES_CHECK_PORTS"
		exit 1
	fi
}

if ! command -v ss >/dev/null 2>&1; then
	if command -v dpkg-query >/dev/null 2>&1; then
		apt-get install -yq -o DPkg::Lock::Timeout=60 iproute2
	else
		${package_manager} -y install iproute
	fi
fi

# A dependency that is already installed gets reused by install-preq, so its port is expected to be busy
DOCUMENT_SERVER_PORTS="8083 8000 8080"
add_dependency_port() {
	local PORT="$1" PACKAGE_NAME INSTALLED_NAME
	shift

	for PACKAGE_NAME in "$@"; do
		if INSTALLED_NAME=$(dependency_installed "${PACKAGE_NAME}"); then
			echo "${INSTALLED_NAME} $RES_APP_INSTALLED"
			return 0
		fi
	done
	DOCUMENT_SERVER_PORTS+=" ${PORT}"
}

if [ "${UPDATE}" != "true" ]; then
	# Debian and RPM distros use different PostgreSQL server package names.
	if command -v dpkg-query >/dev/null 2>&1; then
		add_dependency_port 5432 postgresql 'postgresql-[0-9]*'
	else
		add_dependency_port 5432 postgresql-server
	fi
	add_dependency_port 5672 rabbitmq-server
	add_dependency_port 6379 redis-server redis valkey
fi

check_component COMMUNITY_SERVER_INSTALLED "80 443 5280 9888 9866 9871 9882" "${package_sysname}-communityserver"
check_component XMPP_SERVER_INSTALLED "5222 9865" "${package_sysname}-xmppserver"
check_component DOCUMENT_SERVER_INSTALLED "${DOCUMENT_SERVER_PORTS}" "${package_sysname}-documentserver" "${package_sysname}-documentserver-de" "${package_sysname}-documentserver-ee"
check_component CONTROL_PANEL_INSTALLED "8082 9833 9834" "${package_sysname}-controlpanel"

if [ "$CONTROL_PANEL_INSTALLED" = "true" ] || [ "$COMMUNITY_SERVER_INSTALLED" = "true" ] || [ "$XMPP_SERVER_INSTALLED" = "true" ] || [ "$DOCUMENT_SERVER_INSTALLED" = "true" ]; then
	if [ "$UPDATE" != "true" ]; then
		echo "To update the installed components, run the script with the parameter: --update true"
		exit 1
	fi
fi
