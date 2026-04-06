#!/bin/bash

set -e

cat<<EOF

#######################################
#  INSTALL PREREQUISITES
#######################################

EOF

locale-gen en_US.UTF-8

# add redis repo
if [ "$DIST" = "ubuntu" ]; then
	curl -fsSL https://packages.redis.io/gpg | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/redis.gpg --import
	echo "deb [signed-by=/usr/share/keyrings/redis.gpg] https://packages.redis.io/deb $DISTRIB_CODENAME main" | tee /etc/apt/sources.list.d/redis.list
	chmod 644 /usr/share/keyrings/redis.gpg
fi

#add dotnet repo
if [ "$DIST" = "debian" ]; then
	curl -fsSL https://packages.microsoft.com/config/$DIST/$REV/packages-microsoft-prod.deb -O
	echo -e "Package: *\nPin: origin \"packages.microsoft.com\"\nPin-Priority: 1002" | tee /etc/apt/preferences.d/99microsoft-prod.pref
	DEBIAN_FRONTEND=noninteractive dpkg --force-confnew -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb
elif dpkg -l | grep -q packages-microsoft-prod; then
    apt-get purge -y packages-microsoft-prod
fi

# add elasticsearch repo
if [ -z "$ELASTICSEARCH_REPOSITORY" ]; then
	curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/elastic-7.x.gpg --import
	chmod 644 /usr/share/keyrings/elastic-7.x.gpg
	echo "deb [signed-by=/usr/share/keyrings/elastic-7.x.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
fi

# add nodejs repo
curl -fsSL https://deb.nodesource.com/setup_16.x | sed '/sleep/d' | bash -

#add nginx repo
if [[ ! "$DISTRIB_CODENAME" =~ ^(noble|trixie)$ ]]; then
	curl -fsSL http://nginx.org/keys/nginx_signing.key | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/nginx.gpg --import
	chmod 644 /usr/share/keyrings/nginx.gpg
	echo "deb [signed-by=/usr/share/keyrings/nginx.gpg] http://nginx.org/packages/$DIST/ $DISTRIB_CODENAME nginx" | tee /etc/apt/sources.list.d/nginx.list
	#Temporary fix for missing nginx repository for debian bookworm
	[ "$DISTRIB_CODENAME" = "bookworm" ] && sed -i "s/$DISTRIB_CODENAME/buster/g" /etc/apt/sources.list.d/nginx.list
fi

# setup msttcorefonts
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

MYSQL_REPO_VERSION="$(curl -fsSL https://dev.mysql.com/downloads/repo/apt/ | grep -oP '(?<=mysql-apt-config_)[0-9.]+-[0-9]+(?=_all\.deb)' | head -n1)"
MYSQL_PACKAGE_NAME="mysql-apt-config_${MYSQL_REPO_VERSION}_all.deb"
if ! dpkg -l | grep -q "mysql-server"; then

MYSQL_SERVER_HOST=${MYSQL_SERVER_HOST:-"localhost"}
MYSQL_SERVER_PORT=${MYSQL_SERVER_PORT:-"3306"}
MYSQL_SERVER_DB_NAME=${MYSQL_SERVER_DB_NAME:-"${package_sysname}"}
MYSQL_SERVER_USER=${MYSQL_SERVER_USER:-"root"}
MYSQL_SERVER_PASS=${MYSQL_SERVER_PASS:-"$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)"}

# setup mysql 8.4 package
curl -fsSLO http://repo.mysql.com/"${MYSQL_PACKAGE_NAME}"
echo "mysql-apt-config mysql-apt-config/repo-codename  select  $DISTRIB_CODENAME" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/repo-distro  select  $DIST" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-server  select  mysql-8.4-lts" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg -i "${MYSQL_PACKAGE_NAME}"
rm -f "${MYSQL_PACKAGE_NAME}"

echo mysql-community-server mysql-community-server/root-pass password "${MYSQL_SERVER_PASS}" | debconf-set-selections
echo mysql-community-server mysql-community-server/re-root-pass password "${MYSQL_SERVER_PASS}" | debconf-set-selections
echo mysql-community-server mysql-server/default-auth-override select "Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections
echo mysql-server mysql-server/root_password password "${MYSQL_SERVER_PASS}" | debconf-set-selections
echo mysql-server mysql-server/root_password_again password "${MYSQL_SERVER_PASS}" | debconf-set-selections

elif dpkg -l | grep -q "mysql-apt-config" && [ "$(apt-cache policy mysql-apt-config | awk 'NR==2{print $2}')" != "${MYSQL_REPO_VERSION}" ]; then
	curl -fsSLO http://repo.mysql.com/"${MYSQL_PACKAGE_NAME}"
	DEBIAN_FRONTEND=noninteractive dpkg -i "${MYSQL_PACKAGE_NAME}"
	rm -f "${MYSQL_PACKAGE_NAME}"
fi

# add certbot
if [ "$DIST" = "ubuntu" ]; then
	command_exists snap || apt-get -y install snapd
	snap install --classic certbot
else
	apt-get install -yq certbot
fi

if apt-get install --dry-run ruby-god 2>/dev/null; then
	apt-get install -yq ruby-god ruby-dev
else
	command_exists ruby || apt-get install -yq build-essential libssl-dev libreadline-dev zlib1g-dev ruby-full
	command_exists god || gem install --bindir /usr/bin "$(ruby -e 'puts RUBY_VERSION > "3" ? "resurrected_god" : "god"')" --no-document
fi

# add mono official repo (Debian uses stable-buster, Ubuntu uses stable-focal)
MONO_DISTRO="stable-buster"; [ "$DIST" = "ubuntu" ] && MONO_DISTRO="stable-focal"
MONO_OPTS="[signed-by=/usr/share/keyrings/mono-official-stable.gpg]"
[ "$DISTRIB_CODENAME" = "trixie" ] && MONO_OPTS="[trusted=yes]"  # SHA1 key rejected by Debian 13 sqv
echo "deb $MONO_OPTS https://download.mono-project.com/repo/$DIST $MONO_DISTRO/snapshots/6.8.0.123 main" | tee /etc/apt/sources.list.d/mono-official.list
gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/mono-official-stable.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF || true
chmod 644 /usr/share/keyrings/mono-official-stable.gpg
# Pin mono packages to prefer mono-project repo over system mono (e.g. Debian 13 has mono 6.12)
printf 'Package: mono-* libmono-* libmonosgen-* libmonoboehm-* ca-certificates-mono monodoc-*\nPin: origin download.mono-project.com\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mono-project.pref

# add mono extra repo (focal works for all supported distros)
echo "deb [signed-by=/usr/share/keyrings/mono-extra.gpg] https://d2nlctn12v279m.cloudfront.net/repo/mono/ubuntu focal main" | tee /etc/apt/sources.list.d/mono-extra.list
curl -fsSL https://d2nlctn12v279m.cloudfront.net/repo/mono/mono.key | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/mono-extra.gpg --import
chmod 644 /usr/share/keyrings/mono-extra.gpg

apt-get update -y
MONO_COMPLETE_VERSION=$(apt-cache madison mono-complete | grep "| 6.8.0.123" | sed -n '1p' | cut -d'|' -f2 | tr -d ' ')
CURRENT_MYSQL_VERSION=$(dpkg-query -W -f='${Version}' "mysql-client" || true) 
AVAILABLE_MYSQL_VERSION=$(apt-cache policy "mysql-client" | awk 'NR==3{print $2}')

# install
apt-get install -o DPkg::options::="--force-confnew" -yq wget \
				cron \
				mono-complete=${MONO_COMPLETE_VERSION} \
				ca-certificates-mono \
				mono-webserver-hyperfastcgi=0.4-8 \
				nodejs \
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
				dotnet-sdk-8.0

# Remove default-authentication-plugin from MySQL config — option removed in MySQL 8.4, causes startup failure
find /etc/mysql -name "*.cnf" -exec sed -i '/^default-authentication-plugin/d' {} \; 2>/dev/null || true

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

hold_package_version
