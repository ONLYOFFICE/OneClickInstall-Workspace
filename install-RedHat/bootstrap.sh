#!/bin/bash

set -e

cat<<EOF

#######################################
#  BOOTSTRAP
#######################################

EOF

if ! rpm -q iproute; then
	${package_manager} -y install iproute
fi