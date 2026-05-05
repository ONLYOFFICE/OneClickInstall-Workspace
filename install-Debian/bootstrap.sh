#!/bin/bash

set -e

cat<<EOF

#######################################
#  BOOTSTRAP
#######################################

EOF

export NEEDRESTART_MODE=a
apt-get -y update

if ! dpkg -l | grep -q "sudo"; then
	apt-get install -yq sudo
fi

if ! dpkg -l | grep -q "net-tools"; then
	apt-get install -yq net-tools
fi

if ! dpkg -l | grep -q "dirmngr"; then
	apt-get install -yq dirmngr
fi

if ! dpkg -l | grep -q "debian-archive-keyring"; then
	apt-get install -yq debian-archive-keyring || true
fi

if ! dpkg -l | grep -q "debconf-utils"; then
	apt-get install -yq debconf-utils
fi

if ! dpkg -l | grep -q "wget"; then
	apt-get install -yq wget
fi

if ! command -v locale-gen &> /dev/null; then
	apt-get install -yq locales
fi

if ! dpkg -l | grep -q "apt-transport-https"; then
	apt-get install -yq apt-transport-https
fi

if ! dpkg -l | grep -q "software-properties-common"; then
	apt-get install -yq software-properties-common || true
fi

if ! dpkg -s syslog-ng &>/dev/null; then
	apt-get install -yq rsyslog
fi
