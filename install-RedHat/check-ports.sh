#!/bin/bash

set -e

cat<<EOF

#######################################
#  CHECK PORTS
#######################################

EOF

if rpm -q ${package_sysname}-communityserver; then
	echo "${package_sysname}-communityserver $RES_APP_INSTALLED"
	COMMUNITY_SERVER_INSTALLED="true";
elif [ "${UPDATE}" != "true" ] && netstat -lnp | awk '{print $4}' | grep -qE ":80$|:443$|:5280$|:9888$|:9866$|:9871$|:9882$"; then
	echo "${package_sysname}-communityserver $RES_APP_CHECK_PORTS: 80, 443,  5280, 9888, 9866, 9871, 9882";
	echo "$RES_CHECK_PORTS"
	exit
else
	COMMUNITY_SERVER_INSTALLED="false";
fi

if rpm -q "${package_sysname}-xmppserver"; then
	echo "${package_sysname}-xmppserver $RES_APP_INSTALLED"
	XMPP_SERVER_INSTALLED="true";
elif [ "${UPDATE}" != "true" ] && netstat -lnp | awk '{print $4}' | grep -qE ":5222$|:9865$"; then
	echo "${package_sysname}-xmppserver $RES_APP_CHECK_PORTS: 5222, 9865";
	echo "$RES_CHECK_PORTS"
	exit
else
	XMPP_SERVER_INSTALLED="false";
fi

if rpm -qa | grep ${package_sysname}-documentserver; then
	echo "${package_sysname}-documentserver $RES_APP_INSTALLED"
	DOCUMENT_SERVER_INSTALLED="true";
elif [ "${UPDATE}" != "true" ] && netstat -lnp | awk '{print $4}' | grep -qE ":8083$|:5432$|:5672$|:6379$|:8000$|:8080$"; then
	echo "${package_sysname}-documentserver $RES_APP_CHECK_PORTS: 8083, 5432, 5672, 6379, 8000, 8080";
	echo "$RES_CHECK_PORTS"
	exit
else
	DOCUMENT_SERVER_INSTALLED="false";
fi

if rpm -q ${package_sysname}-controlpanel; then
	echo "${package_sysname}-controlpanel $RES_APP_INSTALLED"
	CONTROL_PANEL_INSTALLED="true";
elif [ "${UPDATE}" != "true" ] && netstat -lnp | awk '{print $4}' | grep -qE ":8082$|:9833$|:9834$"; then
	echo "${package_sysname}-controlpanel $RES_APP_CHECK_PORTS: 8082, 9833, 9834";
	echo "$RES_CHECK_PORTS"
	exit
else
	CONTROL_PANEL_INSTALLED="false";
fi

if [ "$CONTROL_PANEL_INSTALLED" = "true" ] || [ "$COMMUNITY_SERVER_INSTALLED" = "true" ] || [ "$XMPP_SERVER_INSTALLED" = "true" ] || [ "$DOCUMENT_SERVER_INSTALLED" = "true" ]; then
	if [ "$UPDATE" != "true" ]; then
		exit;	
	fi
fi