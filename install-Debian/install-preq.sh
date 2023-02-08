#!/bin/bash

set -e

cat<<EOF

#######################################
#  INSTALL PREREQUISITES
#######################################

EOF

rm -f /etc/apt/sources.list.d/builds-ubuntu-sphinxsearch-rel22-bionic.list
rm -f /etc/apt/sources.list.d/certbot-ubuntu-certbot-bionic.list
rm -f /etc/apt/sources.list.d/mono-official.list

if [ "$DIST" = "debian" ] && [ $(apt-cache search ttf-mscorefonts-installer | wc -l) -eq 0 ]; then
		echo "deb http://ftp.uk.debian.org/debian/ $DISTRIB_CODENAME main contrib" >> /etc/apt/sources.list
		echo "deb-src http://ftp.uk.debian.org/debian/ $DISTRIB_CODENAME main contrib" >> /etc/apt/sources.list
fi

apt-get -y update

if ! command -v locale-gen &> /dev/null; then
	apt-get install -yq locales
fi

if ! dpkg -l | grep -q "apt-transport-https"; then
	apt-get install -yq apt-transport-https
fi

if ! dpkg -l | grep -q "software-properties-common"; then
	apt-get install -yq software-properties-common
fi

locale-gen en_US.UTF-8
if [ -f /etc/needrestart/needrestart.conf ]; then
	sed -e "s_#\$nrconf{restart}_\$nrconf{restart}_" -e "s_\(\$nrconf{restart} =\).*_\1 'a';_" -i /etc/needrestart/needrestart.conf
fi

#Fix kinetic dependencies
if [ "$DISTRIB_CODENAME" = "jammy" ] && [ $(apt-cache search "libevent-2.1-7$" | wc -l) -eq 0 ]; then
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/ubuntu-keyring-2018-archive.gpg] http://archive.ubuntu.com/ubuntu/ $DISTRIB_CODENAME main" | tee /etc/apt/sources.list.d/$DISTRIB_CODENAME.list
    apt-get update && apt-get install -yq libevent-2.1-7
    rm -f /etc/apt/sources.list.d/$DISTRIB_CODENAME.list
fi

# add mono extra repo
echo "deb [signed-by=/usr/share/keyrings/mono-official-stable.gpg] https://download.mono-project.com/repo/$DIST stable-$DISTRIB_CODENAME/snapshots/6.8.0.123 main" | tee /etc/apt/sources.list.d/mono-official.list
if [ "$DISTRIB_CODENAME" = "bullseye" ]; then sed -i 's/stable-bullseye/stable-buster/g' /etc/apt/sources.list.d/mono-official.list; fi; #Fix missing repository for bullseye
if [ "$DISTRIB_CODENAME" = "jammy" ]; then sed -i 's/stable-jammy/stable-focal/g' /etc/apt/sources.list.d/mono-official.list; fi; #Fix missing repository for jammy

gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/mono-official-stable.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
chmod 644 /usr/share/keyrings/mono-official-stable.gpg
mono_complete_package_version=$(apt-cache madison mono-complete | grep "| 6.8.0.123" | sed -n '1p' | cut -d'|' -f2 | tr -d ' ')

if [[ "$DIST" = "ubuntu" || "$DIST" = "debian" ]] && [[ "$DISTRIB_CODENAME" = "focal" || "$DISTRIB_CODENAME" = "bullseye" || "$DISTRIB_CODENAME" = "jammy" ]]; then
	echo "deb [signed-by=/usr/share/keyrings/mono-extra.gpg] https://d2nlctn12v279m.cloudfront.net/repo/mono/ubuntu focal main" | tee /etc/apt/sources.list.d/mono-extra.list  
	hyperfastcgi_version="0.4-8"
elif [[ "$DIST" = "ubuntu" || "$DIST" = "debian" ]] && [[ "$DISTRIB_CODENAME" = "bionic" || "$DISTRIB_CODENAME" = "buster"  ]]; then
	echo "deb [signed-by=/usr/share/keyrings/mono-extra.gpg] https://d2nlctn12v279m.cloudfront.net/repo/mono/ubuntu bionic main" | tee /etc/apt/sources.list.d/mono-extra.list  
	hyperfastcgi_version="0.4-7"
else
	echo "deb [signed-by=/usr/share/keyrings/mono-extra.gpg] https://d2nlctn12v279m.cloudfront.net/repo/mono/ubuntu xenial main" | tee /etc/apt/sources.list.d/mono-extra.list  
	hyperfastcgi_version="0.4-6"
fi

# add mono extra key
curl -fsSL https://d2nlctn12v279m.cloudfront.net/repo/mono/mono.key | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/mono-extra.gpg --import
chmod 644 /usr/share/keyrings/mono-extra.gpg

if [ "$DIST" = "ubuntu" ]; then	
	# add redis repo
	curl -fsSL https://packages.redis.io/gpg | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/redis.gpg --import
	echo "deb [signed-by=/usr/share/keyrings/redis.gpg] https://packages.redis.io/deb $DISTRIB_CODENAME main" | tee /etc/apt/sources.list.d/redis.list
	chmod 644 /usr/share/keyrings/redis.gpg

	# ffmpeg
	if [ "$DISTRIB_CODENAME" = "trusty" ]; then
		add-apt-repository ppa:mc3man/trusty-media
	fi		
fi

#add dotnet repo
if [ "$DIST" = "debian" ] && [ "$DISTRIB_CODENAME" = "stretch" ]; then
	curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
	wget -O /etc/apt/sources.list.d/microsoft-prod.list https://packages.microsoft.com/config/debian/9/prod.list
elif [ "$DISTRIB_CODENAME" != "jammy" ]; then
	curl https://packages.microsoft.com/config/$DIST/$REV/packages-microsoft-prod.deb -O
	dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb
elif dpkg -l | grep -q "packages-microsoft-prod"; then 
	apt-get purge -y packages-microsoft-prod dotnet*
fi

if [ -z $ELASTICSEARCH_REPOSITORY ]; then
	# add elasticsearch repo
	curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/elastic-7.x.gpg --import
	chmod 644 /usr/share/keyrings/elastic-7.x.gpg
	echo "deb [signed-by=/usr/share/keyrings/elastic-7.x.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
fi
# add nodejs repo
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_12.x $DISTRIB_CODENAME main" | tee /etc/apt/sources.list.d/nodesource.list
echo "deb-src [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_12.x $DISTRIB_CODENAME main" >> /etc/apt/sources.list.d/nodesource.list
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/nodesource.gpg --import
chmod 644 /usr/share/keyrings/nodesource.gpg
if [ "$DISTRIB_CODENAME" = "jammy" ]; then sed -i 's/jammy/focal/g' /etc/apt/sources.list.d/nodesource.list; fi; #Fix missing repository for jammy

apt-get update

node_version=$(apt-cache madison nodejs | grep "| 12." | sed -n '1p' | cut -d'|' -f2 | tr -d ' ')
mono_complete_version=$(apt-cache madison mono-complete | grep "| 6.8.0.123" | sed -n '1p' | cut -d'|' -f2 | tr -d ' ')

#add nginx repo
curl -s http://nginx.org/keys/nginx_signing.key | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/nginx.gpg --import
chmod 644 /usr/share/keyrings/nginx.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx.gpg] http://nginx.org/packages/$DIST/ $DISTRIB_CODENAME nginx" | tee /etc/apt/sources.list.d/nginx.list

# setup msttcorefonts
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

MYSQL_REPO_VERSION="$(curl https://repo.mysql.com | grep -oP 'mysql-apt-config_\K.*' | grep -o '^[^_]*' | sort --version-sort --field-separator=. | tail -n1)"
MYSQL_PACKAGE_NAME="mysql-apt-config_${MYSQL_REPO_VERSION}_all.deb"
if ! dpkg -l | grep -q "mysql-server"; then

MYSQL_SERVER_HOST=${MYSQL_SERVER_HOST:-"localhost"}
MYSQL_SERVER_DB_NAME=${MYSQL_SERVER_DB_NAME:-"${package_sysname}"}
MYSQL_SERVER_USER=${MYSQL_SERVER_USER:-"root"}
MYSQL_SERVER_PASS=${MYSQL_SERVER_PASS:-"$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)"}

# setup mysql 8.0 package
curl -OL http://repo.mysql.com/${MYSQL_PACKAGE_NAME}
echo "mysql-apt-config mysql-apt-config/repo-codename  select  $DISTRIB_CODENAME" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/repo-distro  select  $DIST" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-server  select  mysql-8.0" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg -i ${MYSQL_PACKAGE_NAME}
rm -f ${MYSQL_PACKAGE_NAME}

echo mysql-community-server mysql-community-server/root-pass password ${MYSQL_SERVER_PASS} | debconf-set-selections
echo mysql-community-server mysql-community-server/re-root-pass password ${MYSQL_SERVER_PASS} | debconf-set-selections
echo mysql-community-server mysql-server/default-auth-override select "Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections
echo mysql-server-8.0 mysql-server/root_password password ${MYSQL_SERVER_PASS} | debconf-set-selections
echo mysql-server-8.0 mysql-server/root_password_again password ${MYSQL_SERVER_PASS} | debconf-set-selections

apt-get -y update
elif dpkg -l | grep -q "mysql-apt-config" && [ "$(apt-cache policy mysql-apt-config | awk 'NR==2{print $2}')" != "${MYSQL_REPO_VERSION}" ]; then
	curl -OL http://repo.mysql.com/${MYSQL_PACKAGE_NAME}
	DEBIAN_FRONTEND=noninteractive dpkg -i ${MYSQL_PACKAGE_NAME}
	rm -f ${MYSQL_PACKAGE_NAME}
	apt-get -y update
fi

if [ "$DIST" = "debian" ] && [ "$DISTRIB_CODENAME" = "stretch" ]; then
	apt-get install -yq mysql-server mysql-client --allow-unauthenticated
fi

# add certbot repo
if [ "$DIST" = "ubuntu" ] && [[ "$DISTRIB_CODENAME" = "focal" || "$DISTRIB_CODENAME" = "jammy" ]]; then
	if ! command_exists snap; then
		apt-get -y install snapd
	fi
	snap install --classic certbot
elif [ "$DIST" = "ubuntu" ]; then
	add-apt-repository -y ppa:certbot/certbot
	apt-get -y update	
	apt-get install -yq certbot
elif [ "$DIST" = "debian" ] && [[ "$DISTRIB_CODENAME" = "stretch"  || "$DISTRIB_CODENAME" = "buster" || "$DISTRIB_CODENAME" = "bullseye" ]]; then
	apt-get install -yq certbot
elif [ "$DIST" = "debian" ] && [ "$DISTRIB_CODENAME" = "jessie" ]; then # Debian 8
	echo "deb http://ftp.debian.org/debian jessie-backports main" | tee /etc/apt/sources.list.d/jessie_backports.list
	echo "deb http://www.deb-multimedia.org jessie main non-free" | tee /etc/apt/sources.list.d/deb_multimedia.list

	apt-get -y update
	apt-get install -yq certbot -t jessie-backports
	apt-get install -yq deb-multimedia-keyring		
fi

# install
apt-get install -o DPkg::options::="--force-confnew" -yq wget \
				cron \
				rsyslog \
				ruby-dev \
				ruby-god \
				mono-complete=$mono_complete_version \
				ca-certificates-mono \
				mono-webserver-hyperfastcgi=$hyperfastcgi_version \
				nodejs=$node_version \
				mysql-server \
				mysql-client \
				htop \
				nano \
				dnsutils \
				postgresql \
				redis-server \
				rabbitmq-server \
				apt-transport-https \
				python3-pip \
				nginx-extras \
				expect \
				dotnet-sdk-6.0

if apt-cache search --names-only '^ffmpeg$' | grep -q "ffmpeg"; then
	apt-get install -yq ffmpeg
fi
		
if [ -e /etc/redis/redis.conf ]; then
 sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf
 sed -r "/^save\s[0-9]+/d" -i /etc/redis/redis.conf
 
 service redis-server restart
fi
	
if ! dpkg -l | grep -q "elasticsearch"; then
	apt-get install -yq elasticsearch=7.16.3
fi
				
npm config set prefix '/usr/'

# disable apparmor for mysql
if which apparmor_parser && [ ! -f /etc/apparmor.d/disable/usr.sbin.mysqld ] && [ -f /etc/apparmor.d/disable/usr.sbin.mysqld ]; then
	ln -sf /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/;
	apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld;
fi