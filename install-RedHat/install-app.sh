#!/bin/bash

set -e

cat<<EOF

#######################################
#  INSTALL APP 
#######################################

EOF

package_manager_update_cmd=${package_manager_update_cmd:-"update"};

if [ -e /etc/redis.conf ]; then
 sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis.conf
 sed -r "/^save\s[0-9]+/d" -i /etc/redis.conf
 
 systemctl restart redis
fi

sed "/host\s*all\s*all\s*127\.0\.0\.1\/32\s*ident$/s|ident$|trust|" -i /var/lib/pgsql/data/pg_hba.conf
sed "/host\s*all\s*all\s*::1\/128\s*ident$/s|ident$|trust|" -i /var/lib/pgsql/data/pg_hba.conf

for SVC in $package_services; do
		systemctl start $SVC	
		systemctl enable $SVC
done

if [ "$UPDATE" = "true" ] && [ "$CONTROL_PANEL_INSTALLED" = "true" ]; then
	${package_manager} -y ${package_manager_update_cmd} ${package_sysname}-controlpanel
fi

if [ "$UPDATE" = "true" ] && [ "$DOCUMENT_SERVER_INSTALLED" = "true" ]; then
	ds_pkg_installed_name=$(rpm -qa --qf '%{NAME}\n' | grep ${package_sysname}-documentserver);

	if [ "$INSTALLATION_TYPE" = "GROUPS" ]; then
		${package_manager} -y remove ${ds_pkg_installed_name}

		DOCUMENT_SERVER_INSTALLED="false"
	fi

	if [ "$INSTALLATION_TYPE" = "WORKSPACE" ]; then
		ds_pkg_name="${package_sysname}-documentserver";
	fi

	if [ "$INSTALLATION_TYPE" = "WORKSPACE_ENTERPRISE" ]; then
		ds_pkg_name="${package_sysname}-documentserver-ee";
	fi

	if [ -n $ds_pkg_name ]; then
		if ! rpm -qi ${ds_pkg_name} &> /dev/null; then
			${package_manager} -y remove ${ds_pkg_installed_name}

			DOCUMENT_SERVER_INSTALLED="false"
		else
			${package_manager} -y ${package_manager_update_cmd} ${ds_pkg_name}	
		fi				
	fi
fi

if [ "$UPDATE" = "true" ] && [ "$XMPP_SERVER_INSTALLED" = "true" ]; then
    if [ "$INSTALLATION_TYPE" = "GROUPS" ]; then
		${package_manager} -y remove ${package_sysname}-xmppserver
		XMPP_SERVER_INSTALLED="false"
	else
		${package_manager} -y ${package_manager_update_cmd} ${package_sysname}-xmppserver	
	fi	
fi

MYSQL_SERVER_HOST=${MYSQL_SERVER_HOST:-"localhost"}
MYSQL_SERVER_DB_NAME=${MYSQL_SERVER_DB_NAME:-"${package_sysname}"}
MYSQL_SERVER_USER=${MYSQL_SERVER_USER:-"root"}
MYSQL_SERVER_PASS=${MYSQL_SERVER_PASS:-"bbThb75KEvbxczk2019!"}
MYSQL_SERVER_PORT=${MYSQL_SERVER_PORT:-3306}

if [ "$COMMUNITY_SERVER_INSTALLED" = "true" ]; then	
	DIR="/var/www/${package_sysname}/WebStudio";

	MYSQL_SERVER_HOST=$(grep -oP "Server=[^\";]*" $DIR/web.connections.config | head -1 | cut -d'=' -f2);
	MYSQL_SERVER_DB_NAME=$(grep -oP "Database=[^\";]*" $DIR/web.connections.config | head -1 | cut -d'=' -f2);
	MYSQL_SERVER_USER=$(grep -oP "User ID=[^\";]*" $DIR/web.connections.config | head -1 | cut -d'=' -f2);
	MYSQL_SERVER_PASS=$(grep -oP "Password=[^\";]*" $DIR/web.connections.config | head -1 | cut -d'=' -f2);
fi

if [ "${MYSQL_FIRST_TIME_INSTALL}" = "true" ]; then
	MYSQL_TEMPORARY_ROOT_PASS="";

	if [ -f "/var/log/mysqld.log" ]; then
		MYSQL_TEMPORARY_ROOT_PASS=$(cat /var/log/mysqld.log | grep "temporary password" | rev | cut -d " " -f 1 | rev | tail -1);
	fi

	while ! mysqladmin ping -u root --silent; do
		sleep 1
	done

	if ! mysql "-u$MYSQL_SERVER_USER" "-p$MYSQL_SERVER_PASS" -e ";" >/dev/null 2>&1; then
		if [ -z $MYSQL_TEMPORARY_ROOT_PASS ]; then
		   MYSQL="mysql --connect-expired-password -u$MYSQL_SERVER_USER -D mysql";
		else
		   MYSQL="mysql --connect-expired-password -u$MYSQL_SERVER_USER -p${MYSQL_TEMPORARY_ROOT_PASS} -D mysql";
		fi

		MYSQL_AUTHENTICATION_PLUGIN=$($MYSQL -e "SHOW VARIABLES LIKE 'default_authentication_plugin';" -s | awk '{print $2}')
		MYSQL_AUTHENTICATION_PLUGIN=${MYSQL_AUTHENTICATION_PLUGIN:-caching_sha2_password}

		$MYSQL -e "ALTER USER '${MYSQL_SERVER_USER}'@'localhost' IDENTIFIED WITH ${MYSQL_AUTHENTICATION_PLUGIN} BY '${MYSQL_SERVER_PASS}'" >/dev/null 2>&1 \
		|| $MYSQL -e "UPDATE user SET plugin='${MYSQL_AUTHENTICATION_PLUGIN}', authentication_string=PASSWORD('${MYSQL_SERVER_PASS}') WHERE user='${MYSQL_SERVER_USER}' and host='localhost';"

		systemctl restart mysqld
	fi
fi

if [ "$INSTALLATION_TYPE" != "GROUPS" ] && [ "$DOCUMENT_SERVER_INSTALLED" = "false" ]; then
	declare -x DS_PORT=8083

	DS_RABBITMQ_HOST=localhost;
	DS_RABBITMQ_USER=guest;
	DS_RABBITMQ_PWD=guest;
	
	DS_REDIS_HOST=localhost;
	
	DS_COMMON_NAME=${DS_COMMON_NAME:-"ds"};

	DS_DB_HOST=localhost;
	DS_DB_NAME=$DS_COMMON_NAME;
	DS_DB_USER=$DS_COMMON_NAME;
	DS_DB_PWD=$DS_COMMON_NAME;
	
	declare -x JWT_ENABLED=true;
	declare -x JWT_SECRET="$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)";
	declare -x JWT_HEADER="AuthorizationJwt";
		
	if ! su - postgres -s /bin/bash -c "psql -lqt" | cut -d \| -f 1 | grep -q ${DS_DB_NAME}; then
		su - postgres -s /bin/bash -c "psql -c \"CREATE USER ${DS_DB_USER} WITH password '${DS_DB_PWD}';\""
		su - postgres -s /bin/bash -c "psql -c \"CREATE DATABASE ${DS_DB_NAME} OWNER ${DS_DB_USER};\""
	fi
	
	if [ "$INSTALLATION_TYPE" = "WORKSPACE" ]; then	
		${package_manager} -y install ${package_sysname}-documentserver
	else
		${package_manager} -y install ${package_sysname}-documentserver-ee
	fi
	
expect << EOF
	
	set timeout -1
	log_user 1
	
	spawn documentserver-configure.sh
	
	expect "Configuring database access..."
	
	expect -re "Host"
	send "\025$DS_DB_HOST\r"
	
	expect -re "Database name"
	send "\025$DS_DB_NAME\r"
	
	expect -re "User"
	send "\025$DS_DB_USER\r"
	
	expect -re "Password"
	send "\025$DS_DB_PWD\r"
	
	if { "${INSTALLATION_TYPE}" == "WORKSPACE_ENTERPRISE" } {
		expect "Configuring redis access..."
		send "\025$DS_REDIS_HOST\r"
	}
	
	expect "Configuring AMQP access... "
	expect -re "Host"
	send "\025$DS_RABBITMQ_HOST\r"
	
	expect -re "User"
	send "\025$DS_RABBITMQ_USER\r"
	
	expect -re "Password"
	send "\025$DS_RABBITMQ_PWD\r"
	
	expect eof
	
EOF
	
	systemctl restart nginx
	systemctl enable nginx

	DOCUMENT_SERVER_INSTALLED="true";
fi

if [ "$CONTROL_PANEL_INSTALLED" = "false" ]; then

	declare -x CONTROLPANEL_DB_PORT=${CONTROLPANEL_DB_PORT:8082}

	${package_manager} -y install ${package_sysname}-controlpanel

	CONTROL_PANEL_INSTALLED="true";
fi

if [ "$UPDATE" = "true" ] && [ "$COMMUNITY_SERVER_INSTALLED" = "true" ]; then
	if [ -z "$REV" ] || [ "$REV" -eq "7" ]; then # hack
		ELASTIC_SEARCH_VERSION=$(rpm -qi elasticsearch | grep Version | tail -n1 | awk -F': ' '/Version/ {print $2}');
		if [ "${ELASTIC_SEARCH_VERSION}" != "7.16.3" ]; then
			ELASTIC_UPDATED_VERSION="elasticsearch-7.16.3-x86_64.rpm"
			curl -O ${ELASTICSEARCH_REPOSITORY:-https://artifacts.elastic.co/downloads/elasticsearch/}${ELASTIC_UPDATED_VERSION}
		fi
		if [ "${package_manager}" = "yum" ]; then
			{ ${package_manager} check-update ${package_sysname}-communityserver; COMMUNITY_CHECK_UPDATE=$?; } || true

			if [[ $COMMUNITY_CHECK_UPDATE -eq $UPDATE_AVAILABLE_CODE ]]; then
				yumdownloader ${package_sysname}-communityserver
				COMMUNITY_UPDATED_VERSION=${package_sysname}-communityserver*
			fi
		elif [ "${package_manager}" = "apt-get" ]; then
			COMMUNITY_INSTALLED_VERSION=$(apt-cache policy ${package_sysname}-communityserver | awk 'NR==2{print $2}')
			COMMUNITY_LATEST_VERSION=$(apt-cache policy ${package_sysname}-communityserver | awk 'NR==3{print $2}')

			if [ "$COMMUNITY_INSTALLED_VERSION" != "$COMMUNITY_LATEST_VERSION" ]; then 
				if [ -z "${ELASTIC_UPDATED_VERSION}" ]; then
					ELASTIC_PACKAGE_REQUIRED="elasticsearch-7.16.3-x86_64.rpm"
					curl -O ${ELASTICSEARCH_REPOSITORY:-https://artifacts.elastic.co/downloads/elasticsearch/}${ELASTIC_PACKAGE_REQUIRED}
				fi
				apt-get install --reinstall --download-only $ELASTIC_PACKAGE_REQUIRED $ELASTIC_UPDATED_VERSION ${package_sysname}-communityserver
				mv -f /var/cache/apt/archives/${package_sysname}-communityserver_$COMMUNITY_LATEST_VERSION* ${package_sysname}-communityserver.rpm
				COMMUNITY_UPDATED_VERSION=${package_sysname}-communityserver.rpm
			fi
		fi
		if [ -n "${ELASTIC_UPDATED_VERSION}" ] || [ -n "${COMMUNITY_UPDATED_VERSION}" ]; then
			rpm -Uhv $ELASTIC_UPDATED_VERSION $COMMUNITY_UPDATED_VERSION
			rm -f $ELASTIC_PACKAGE_REQUIRED $ELASTIC_UPDATED_VERSION $COMMUNITY_UPDATED_VERSION
		fi
	else
		${package_manager} -y ${package_manager_update_cmd} ${package_sysname}-communityserver		
	fi
fi

if [ "$COMMUNITY_SERVER_INSTALLED" = "false" ]; then

	CS_DB_HOST=${MYSQL_SERVER_HOST};
	CS_DB_NAME=${MYSQL_SERVER_DB_NAME};
	CS_DB_USER=${MYSQL_SERVER_USER};
	CS_DB_PWD=${MYSQL_SERVER_PASS};

	${package_manager} -y install ${package_sysname}-communityserver
	
expect << EOF
	
	set timeout -1
	log_user 1
	
	spawn communityserver-configure.sh
	
	expect -re "Host"
	send "\025$CS_DB_HOST\r"
	
	expect -re "Database name"
	send "\025$CS_DB_NAME\r"
	
	expect -re "User"
	send "\025$CS_DB_USER\r"
	
	expect -re "Password"
	send "\025$CS_DB_PWD\r"
	
	expect eof
	
EOF
	COMMUNITY_SERVER_INSTALLED="true";
fi

if [ "$INSTALLATION_TYPE" != "GROUPS" ] && [ "$XMPP_SERVER_INSTALLED" = "false" ]; then

	XMPP_SERVER_DB_HOST=${MYSQL_SERVER_HOST};
	XMPP_SERVER_DB_NAME=${MYSQL_SERVER_DB_NAME};
	XMPP_SERVER_DB_USER=${MYSQL_SERVER_USER};
	XMPP_SERVER_DB_PWD=${MYSQL_SERVER_PASS};

	${package_manager} -y install ${package_sysname}-xmppserver
	
expect << EOF
	
	set timeout -1
	log_user 1
	
	spawn xmppserver-configure.sh
	
	expect -re "Host"
	send "\025${XMPP_SERVER_DB_HOST}\r"
	
	expect -re "Database name"
	send "\025${XMPP_SERVER_DB_NAME}\r"
	
	expect -re "User"
	send "\025${XMPP_SERVER_DB_USER}\r"
	
	expect -re "Password"
	send "\025${XMPP_SERVER_DB_PWD}\r"
	
	expect eof
	
EOF
	XMPP_SERVER_INSTALLED="true";
fi

NGINX_ROOT_DIR="/etc/nginx"
NGINX_WORKER_PROCESSES=${NGINX_WORKER_PROCESSES:-$(grep processor /proc/cpuinfo | wc -l)};
NGINX_WORKER_CONNECTIONS=${NGINX_WORKER_CONNECTIONS:-$(ulimit -n)};

sed 's/^worker_processes.*/'"worker_processes ${NGINX_WORKER_PROCESSES};"'/' -i ${NGINX_ROOT_DIR}/nginx.conf
sed 's/worker_connections.*/'"worker_connections ${NGINX_WORKER_CONNECTIONS};"'/' -i ${NGINX_ROOT_DIR}/nginx.conf

make_swap

if rpm -q "firewalld"; then
	firewall-cmd --permanent --zone=public --add-service=http
	firewall-cmd --permanent --zone=public --add-service=https
	systemctl restart firewalld.service
fi

systemctl restart nginx

echo ""
echo "$RES_INSTALL_SUCCESS"
echo "$RES_PROPOSAL"
echo "$RES_QUESTIONS"
echo ""
