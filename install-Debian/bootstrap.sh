#!/bin/bash

set -e

cat<<EOF

#######################################
#  BOOTSTRAP
#######################################

EOF

# Suppress interactive apt/needrestart prompts during automated installs
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
apt-get -o DPkg::Lock::Timeout=60 -y update

if ! dpkg -l | grep -q "sudo"; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq sudo
fi

if ! dpkg -l | grep -q "iproute2"; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq iproute2
fi

if ! dpkg -l | grep -q "dirmngr"; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq dirmngr
fi

if ! dpkg -l | grep -q "debian-archive-keyring"; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq debian-archive-keyring || true
fi

if ! dpkg -l | grep -q "debconf-utils"; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq debconf-utils
fi

if ! dpkg -l | grep -q "wget"; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq wget
fi

if ! command -v locale-gen &> /dev/null; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq locales
fi

if ! dpkg -l | grep -q "apt-transport-https"; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq apt-transport-https
fi

if ! dpkg -l | grep -q "software-properties-common"; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq software-properties-common || true
fi

if ! dpkg -s syslog-ng &>/dev/null; then
	apt-get -o DPkg::Lock::Timeout=60 install -yq rsyslog
fi
