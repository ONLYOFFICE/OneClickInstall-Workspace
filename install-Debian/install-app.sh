#!/bin/bash

set -e

cat<<EOF

#######################################
#  INSTALL APP 
#######################################

EOF
apt-get -y update

if [ "$UPDATE" = "true" ] && [ "$CONTROL_PANEL_INSTALLED" = "true" ]; then
	apt-get install -y --only-upgrade ${package_sysname}-controlpanel
fi

if [ "$UPDATE" = "true" ] && [ "$DOCUMENT_SERVER_INSTALLED" = "true" ]; then	
	ds_pkg_installed_name=$(dpkg -l | grep ${package_sysname}-documentserver | tail -n1 | awk '{print $2}');

	if [ "$INSTALLATION_TYPE" = "GROUPS" ]; then
		apt-get remove -yq ${ds_pkg_installed_name};

		DOCUMENT_SERVER_INSTALLED="false";
		
		DEBIAN_FRONTEND=noninteractive dpkg-reconfigure ${package_sysname}-communityserver		

	fi

	if [ "$INSTALLATION_TYPE" = "WORKSPACE" ]; then
		ds_pkg_name="${package_sysname}-documentserver";
	fi

	if [ "$INSTALLATION_TYPE" = "WORKSPACE_ENTERPRISE" ]; then
		ds_pkg_name="${package_sysname}-documentserver-ee";
	fi

	if [ -n $ds_pkg_name ]; then
		if ! dpkg -l ${ds_pkg_name} &> /dev/null; then
			
			debconf-get-selections | grep ^${ds_pkg_installed_name} | sed s/${ds_pkg_installed_name}/${ds_pkg_name}/g | debconf-set-selections
						
			apt-get remove -yq ${ds_pkg_installed_name}
			
			apt-get install -yq ${ds_pkg_name}
			
			DEBIAN_FRONTEND=noninteractive dpkg-reconfigure ${package_sysname}-communityserver	
		else
			apt-get install -y --only-upgrade ${ds_pkg_name};	
		fi				
	fi
fi

if [ "$UPDATE" = "true" ] && [ "$COMMUNITY_SERVER_INSTALLED" = "true" ]; then

	apt-get install -o DPkg::options::="--force-confnew" -y --only-upgrade ${package_sysname}-communityserver elasticsearch=7.16.3
	
fi

if [ "$UPDATE" = "true" ] && [ "$XMPP_SERVER_INSTALLED" = "true" ]; then
	apt-get install -y --only-upgrade ${package_sysname}-xmppserver
fi

if [ "$COMMUNITY_SERVER_INSTALLED" = "true" ]; then	
	DIR="/var/www/${package_sysname}/WebStudio";

	MYSQL_SERVER_HOST=$(grep -oP "Server=[^\";]*" $DIR/web.connections.config | head -1 | cut -d'=' -f2);
	MYSQL_SERVER_DB_NAME=$(grep -oP "Database=[^\";]*" $DIR/web.connections.config | head -1 | cut -d'=' -f2);
	MYSQL_SERVER_USER=$(grep -oP "User ID=[^\";]*" $DIR/web.connections.config | head -1 | cut -d'=' -f2);
	MYSQL_SERVER_PASS=$(grep -oP "Password=[^\";]*" $DIR/web.connections.config | head -1 | cut -d'=' -f2);
fi

if [ "$INSTALLATION_TYPE" != "GROUPS" ] && [ "$DOCUMENT_SERVER_INSTALLED" = "false" ]; then
	DS_PORT=${DS_PORT:-8083};

	DS_DB_HOST=localhost;
	DS_DB_NAME=$DS_COMMON_NAME;
	DS_DB_USER=$DS_COMMON_NAME;
	DS_DB_PWD=$DS_COMMON_NAME;

	DS_JWT_ENABLED=${DS_JWT_ENABLED:-true};
	DS_JWT_SECRET="$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)";
	DS_JWT_HEADER="AuthorizationJwt";
	
	if ! su - postgres -s /bin/bash -c "psql -lqt" | cut -d \| -f 1 | grep -q ${DS_DB_NAME}; then
		su - postgres -s /bin/bash -c "psql -c \"CREATE USER ${DS_DB_USER} WITH password '${DS_DB_PWD}';\""
		su - postgres -s /bin/bash -c "psql -c \"CREATE DATABASE ${DS_DB_NAME} OWNER ${DS_DB_USER};\""
	fi

	echo ${package_sysname}-documentserver $DS_COMMON_NAME/ds-port select $DS_PORT | sudo debconf-set-selections
	echo ${package_sysname}-documentserver $DS_COMMON_NAME/db-pwd select $DS_DB_PWD | sudo debconf-set-selections
	echo ${package_sysname}-documentserver $DS_COMMON_NAME/db-user select $DS_DB_USER | sudo debconf-set-selections
	echo ${package_sysname}-documentserver $DS_COMMON_NAME/db-name select $DS_DB_NAME | sudo debconf-set-selections
	echo ${package_sysname}-documentserver $DS_COMMON_NAME/jwt-enabled select ${DS_JWT_ENABLED} | sudo debconf-set-selections
	echo ${package_sysname}-documentserver $DS_COMMON_NAME/jwt-secret select ${DS_JWT_SECRET} | sudo debconf-set-selections
	echo ${package_sysname}-documentserver $DS_COMMON_NAME/jwt-header select ${DS_JWT_HEADER} | sudo debconf-set-selections
	echo ${package_sysname}-documentserver-ee $DS_COMMON_NAME/jwt-enabled select ${DS_JWT_ENABLED} | sudo debconf-set-selections
	echo ${package_sysname}-documentserver-ee $DS_COMMON_NAME/jwt-secret select ${DS_JWT_SECRET} | sudo debconf-set-selections
	echo ${package_sysname}-documentserver-ee $DS_COMMON_NAME/jwt-header select ${DS_JWT_HEADER} | sudo debconf-set-selections

	if [ "$INSTALLATION_TYPE" = "WORKSPACE" ]; then
		apt-get install -yq ${package_sysname}-documentserver
	else
		apt-get install -yq ${package_sysname}-documentserver-ee
	fi
fi

if [ "$CONTROL_PANEL_INSTALLED" = "false" ]; then
	CP_PORT=${CP_PORT:-8082};

	# setup default port
	echo ${package_sysname}-controlpanel ${package_sysname}-controlpanel/port select $CP_PORT | sudo debconf-set-selections

	apt-get install -yq ${package_sysname}-controlpanel
fi

if [ "$COMMUNITY_SERVER_INSTALLED" = "false" ]; then
	echo ${package_sysname} ${package_sysname}-communityserver/ds-jwt-enabled select ${DS_JWT_ENABLED} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-communityserver/ds-jwt-secret select ${DS_JWT_SECRET} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-communityserver/ds-jwt-secret-header select ${DS_JWT_HEADER} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-communityserver/db-host select ${MYSQL_SERVER_HOST} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-communityserver/db-user select ${MYSQL_SERVER_USER} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-communityserver/db-pwd select ${MYSQL_SERVER_PASS} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-communityserver/db-name select ${MYSQL_SERVER_DB_NAME} | sudo debconf-set-selections

	apt-get install -yq ${package_sysname}-communityserver
fi

if [ "$INSTALLATION_TYPE" != "GROUPS" ] && [ "$XMPP_SERVER_INSTALLED" = "false" ]; then
	echo ${package_sysname} ${package_sysname}-xmppserver/db-host select ${MYSQL_SERVER_HOST} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-xmppserver/db-user select ${MYSQL_SERVER_USER} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-xmppserver/db-pwd select ${MYSQL_SERVER_PASS} | sudo debconf-set-selections
	echo ${package_sysname} ${package_sysname}-xmppserver/db-name select ${MYSQL_SERVER_DB_NAME} | sudo debconf-set-selections

	apt-get install -yq ${package_sysname}-xmppserver
	
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure ${package_sysname}-communityserver

fi

NGINX_ROOT_DIR="/etc/nginx"

cp -f ${NGINX_ROOT_DIR}/includes/${package_sysname}-communityserver-nginx.conf.template ${NGINX_ROOT_DIR}/nginx.conf

NGINX_WORKER_PROCESSES=${NGINX_WORKER_PROCESSES:-$(grep processor /proc/cpuinfo | wc -l)};
NGINX_WORKER_CONNECTIONS=${NGINX_WORKER_CONNECTIONS:-$(ulimit -n)};

sed 's/^worker_processes.*/'"worker_processes ${NGINX_WORKER_PROCESSES};"'/' -i ${NGINX_ROOT_DIR}/nginx.conf
sed 's/worker_connections.*/'"worker_connections ${NGINX_WORKER_CONNECTIONS};"'/' -i ${NGINX_ROOT_DIR}/nginx.conf

if ! id "nginx" &>/dev/null; then
	systemctl stop nginx

	rm -dfr /var/log/nginx/*
	rm -dfr /var/cache/nginx/*
	useradd -s /bin/false nginx

	systemctl start nginx
else
	systemctl restart nginx
fi

make_swap

echo ""
echo "$RES_INSTALL_SUCCESS"
echo "$RES_PROPOSAL"
echo "$RES_QUESTIONS"
echo ""
