#!/bin/bash

set -e

cat<<EOF

#######################################
#  INSTALL PREREQUISITES
#######################################

EOF

if rpm -q libmariadb3; then
	echo "Для продолжения установки необходимо удалить MariaDB"
	echo "Выполните команды: \"apt-get remove libmariadb3\" для удаления MariaDB"
	echo "и команду \"rm -rf /var/lib/mysql/db/\" для удаления базы данных"
	exit 0
fi

#Mono repository
apt-repo add "rpm http://git.altlinux.org/repo/262626/ x86_64 task"
mono_version="6.8.0.96-alt1"

if ! rpm -q MySQL-server; then
	MYSQL_FIRST_TIME_INSTALL="true";
fi

apt-get -y update

apt-get -y --force-yes install expect \
            MySQL-client \
			MySQL-server \
			nano \
			htop \
			python3 \
			postgresql9.6 \
			postgresql9.6-server \
			rabbitmq-server \
			redis \
			mono-webserver-hyperfastcgi \
			nodejs \
			npm \
			mono-devel=$mono_version \
			mono-full=$mono_version \
			mono-core=$mono_version \
			mono-data=$mono_version \
			mono-data-oracle=$mono_version \
			mono-data-sqlite=$mono_version \
			mono-devel-full=$mono_version \
			mono-dyndata=$mono_version \
			mono-extras=$mono_version \
			mono-locale-extras=$mono_version \
			mono-mono2-compat=$mono_version \
			mono-mono2-compat-devel=$mono_version \
			mono-monodoc=$mono_version \
			mono-monodoc-devel=$mono_version \
			mono-mvc=$mono_version \
			mono-mvc-devel=$mono_version \
			mono-reactive=$mono_version \
			mono-reactive-devel=$mono_version \
			mono-reactive-winforms=$mono_version \
			mono-wcf=$mono_version \
			mono-web=$mono_version \
			mono-web-devel=$mono_version \
			mono-winforms=$mono_version \
			mono-winfx=$mono_version \
			certbot-nginx \
			fonts-ttf-ms \
			ffmpeg \
			jq \
			gpp \
			make \
			openssl \
			libssl-devel \
			libruby-devel \
			gem \
			dotnet-sdk-6.0
#Installing gpp to fix multiple gcc-c++ packages error #48840

py3_version=$(python3 -c 'import sys; print(sys.version_info.minor)')
if [[ $py3_version -lt 6 ]]; then
	curl -O https://bootstrap.pypa.io/pip/3.$py3_version/get-pip.py
else
	curl -O https://bootstrap.pypa.io/get-pip.py
fi
python3 get-pip.py || true
rm get-pip.py
			
/etc/init.d/postgresql initdb || true

if ! command -v god &> /dev/null; then
	gem install --bindir /usr/bin god
fi

if ! rpm -q elasticsearch; then	
	curl -O ${ELASTICSEARCH_REPOSITORY}elasticsearch-7.16.3-x86_64.rpm
	rpm -ivh elasticsearch-7.16.3-x86_64.rpm
	rm -f elasticsearch-7.16.3-x86_64.rpm
fi

if ! rpm -q msttcore-fonts-installer; then

apt-get install -y xorg-x11-font-utils \
    		   cabextract
			   
curl -O -L https://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

rpm -ivh msttcore-fonts-installer-2.6-1.noarch.rpm
rm msttcore-fonts-installer-2.6-1.noarch.rpm

fi

PATH=$PATH:/sbin

package_services="rabbitmq postgresql redis mysqld elasticsearch"
