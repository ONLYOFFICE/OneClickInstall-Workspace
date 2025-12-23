#!/bin/bash

set -e

cat<<EOF

#######################################
#  INSTALL PREREQUISITES
#######################################

EOF

# clean yum cache
yum clean all

yum -y install yum-utils

DIST=$(rpm -q --whatprovides redhat-release || rpm -q --whatprovides centos-release);
DIST=$(echo $DIST | sed -n '/-.*/s///p');
REV=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//);
REV_PARTS=(${REV//\./ });
REV=${REV_PARTS[0]};
MONOREV=$REV

{ yum check-update postgresql; PSQLExitCode=$?; } || true 
{ yum check-update $DIST*-release; exitCode=$?; } || true #Checking for distribution update

UPDATE_AVAILABLE_CODE=100
if [[ $exitCode -eq $UPDATE_AVAILABLE_CODE ]]; then
	res_unsupported_version
	echo $RES_UNSPPORTED_VERSION
	echo $RES_SELECT_INSTALLATION
	echo $RES_ERROR_REMINDER
	echo $RES_QUESTIONS
	if read_continue_installation; then
		yum -y install $DIST*-release
	else
		exit 0;
	fi
fi

if rpm -qa | grep mariadb.*config >/dev/null 2>&1; then
   echo $RES_MARIADB && exit 0
fi 

if ! [[ "$REV" =~ ^[0-9]+$ ]]; then
	REV=$(cat /etc/redhat-release | sed 's/[^0-9.]*//g');
	MONOREV=7
	if [[ $REV =~ ^7.3[.0-9]*$ ]]; then
		MONOREV=8
		hyperfastcgi_version="0.4-7"

		yum install -y rpm-sign-libs
		if grep -q redhat_kernel_module_package /usr/lib/rpm/redhat/macros; then
			sed -i '/redhat_kernel_module_package/d; /kernel_module_package_release/d' /usr/lib/rpm/redhat/macros
		fi
	fi
	REV_PARTS=(${REV//\./ });
	REV=${REV_PARTS[0]};
fi

#Add EPEL and RPMFusion repository
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$REV.noarch.rpm || true
yum install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$REV.noarch.rpm || true

if [[ "$DIST" == "redhat" && "$REV" -ge 9 ]]; then
    LADSPA_PACKAGE_VERSION=$(curl -s "https://mirror.stream.centos.org/9-stream/CRB/$(arch)/os/Packages/" | grep -oP 'ladspa-[0-9][^"< ]+\.rpm' | sort -V | tail -n 1)
    ${package_manager} install -y "https://mirror.stream.centos.org/9-stream/CRB/$(arch)/os/Packages/${LADSPA_PACKAGE_VERSION}"
fi

if [ "$REV" = "10" ]; then
	hyperfastcgi_version=${hyperfastcgi_version:-"0.4-8"};
	REV="9" && MONOREV="8"
	REDIS_PACKAGE=valkey
	FFMPEG_PACKAGE=ffmpeg-free
	YUM_EXTRA_PARAMS="--nogpgcheck";
elif [ "$REV" = "9" ]; then
	hyperfastcgi_version=${hyperfastcgi_version:-"0.4-8"};
	MONOREV="8"
	[ $DIST != "redhat" ] && TESTING_REPO="--enablerepo=crb" || /usr/bin/crb enable
	update-crypto-policies --set DEFAULT:SHA1
	yum -y install xorg-x11-font-utils
elif [ "$REV" = "8" ]; then
	hyperfastcgi_version=${hyperfastcgi_version:-"0.4-7"};
	[ $DIST != "redhat" ] && POWERTOOLS_REPO="--enablerepo=powertools" || /usr/bin/crb enable
elif [ "$REV" = "7" ] ; then
	hyperfastcgi_version=${hyperfastcgi_version:-"0.4-6"};
fi

REDIS_PACKAGE=${REDIS_PACKAGE:-redis}
FFMPEG_PACKAGE=${FFMPEG_PACKAGE:-ffmpeg}

#add rabbitmq & erlang repo
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | os=centos dist=$REV bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | os=centos dist=$REV bash

if rpm -q rabbitmq-server; then
	if [ "$(yum list installed rabbitmq-server | awk '/rabbitmq-server/ {gsub(/@/, "", $NF); print $NF}')" != "$(repoquery rabbitmq-server --qf='%{repoid}' | tail -n 1)" ]; then
		res_rabbitmq_update
		echo $RES_RABBITMQ_VERSION
		echo $RES_RABBITMQ_REMINDER
		echo $RES_RABBITMQ_INSTALLATION
		if read_continue_installation; then
			rm -rf /var/lib/rabbitmq/mnesia/$(rabbitmqctl eval "node().")
			yum -y remove rabbitmq-server erlang* 
			[ -f "/etc/yum.repos.d/rabbitmq-server.repo" ] && rm -f /etc/yum.repos.d/rabbitmq-server.repo || true
		else
			rm -f /etc/yum.repos.d/rabbitmq_*
		fi
	fi
fi

#add dotnet repo
if [ $REV = "7" ] || [[ $DIST != "redhat" && $REV = "8" ]]; then
	rpm -Uvh https://packages.microsoft.com/config/centos/$REV/packages-microsoft-prod.rpm || true
elif rpm -q packages-microsoft-prod; then
	yum remove -y packages-microsoft-prod dotnet*
fi

#add hyperfastcgi repo
cat > /etc/yum.repos.d/mono-extra.repo <<END
[mono-extra]
name=mono-extra repo
baseurl=https://d2nlctn12v279m.cloudfront.net/repo/mono/centos$MONOREV/main/noarch/
gpgcheck=1
gpgkey=https://d2nlctn12v279m.cloudfront.net/repo/mono/mono.key
enabled=1
END
[[ $hyperfastcgi_version = "0.4-8" ]] && sed -i "s/centos8/centos9/g" /etc/yum.repos.d/mono-extra.repo

#add mysql repo
[ "$REV" != "7" ] && dnf remove -y @mysql && dnf module -y reset mysql && dnf module -y disable mysql
MYSQL_REPO_VERSION="$(curl https://repo.mysql.com | grep -oP "mysql80-community-release-el${REV}-\K.*" | grep -o '^[^.]*' | sort -n | tail -n1)"
yum localinstall -y https://repo.mysql.com/mysql80-community-release-el${REV}-${MYSQL_REPO_VERSION}.noarch.rpm || true

#add mono repo
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" || true
su -c "curl https://download.mono-project.com/repo/centos$MONOREV-stable.repo | tee /etc/yum.repos.d/mono-centos$MONOREV-stable.repo"

# add elasticsearch repo
if [ -z "$ELASTICSEARCH_REPOSITORY" ]; then
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
    {   echo "[elasticsearch]"
        echo "name=Elasticsearch repository for 7.x packages"
        echo "baseurl=https://artifacts.elastic.co/packages/7.x/yum"
        echo "gpgcheck=1"
        echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch"
        echo "enabled=1"
        echo "autorefresh=1"
        echo "type=rpm-md"
    } > /etc/yum.repos.d/elasticsearch.repo
fi

# add nginx repo
cat > /etc/yum.repos.d/nginx.repo <<END
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$REV/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
END

# add nodejs repo
curl -fsSL https://rpm.nodesource.com/setup_16.x | sed '/update -y\|sleep/d' | bash - || true

if ! rpm -q mysql-community-server; then
	MYSQL_FIRST_TIME_INSTALL="true";
elif rpm -q mysql-community-server && [ "$UPDATE" = "true" ]; then
	rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
fi

yum -y install python3-dnf-plugin-versionlock || yum -y install yum-plugin-versionlock
yum versionlock clear

yum -y install epel-release \
			python3 \
			expect \
			nano \
			htop \
			postgresql \
			postgresql-server \
			rabbitmq-server \
			${REDIS_PACKAGE} \
			${FFMPEG_PACKAGE} \
			mysql-community-server \
			mysql-community-client \
			mono-webserver-hyperfastcgi-$hyperfastcgi_version \
			mono-complete-6.8.0.123-0.xamarin.2.epel$MONOREV \
			jq \
			redhat-rpm-config \
			ruby-devel \
			gcc \
			make \
			SDL2 $POWERTOOLS_REPO \
			nodejs $NODEJS_OPTION \
			dotnet-sdk-8.0 \
			${YUM_EXTRA_PARAMS} ${TESTING_REPO}
			
yum versionlock mono-complete
rpm -q elasticsearch || yum install -y elasticsearch-7.16.3-1
command -v god &>/dev/null || gem install --bindir /usr/bin $(ruby -e 'puts RUBY_VERSION > "3" ? "resurrected_god" : "god"') --no-document

PY3_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")'); PIP_URL="https://bootstrap.pypa.io/pip"
PIP_FILE=$(curl --head --silent --fail ${PIP_URL}/${PY3_VER}/get-pip.py > /dev/null && echo ${PIP_URL}/${PY3_VER}/get-pip.py || echo ${PIP_URL}/get-pip.py)
curl -sSL ${PIP_FILE} | python3

if ! command -v certbot &>/dev/null; then
  if yum list available certbot &>/dev/null; then
    yum install -y certbot
  else
    yum install -y snapd
    ln -fs /var/lib/snapd/snap /snap; systemctl start --now snapd.socket; snap wait system seed.loaded
    snap install --classic certbot; ln -s /snap/bin/certbot /usr/bin/certbot
  fi
fi
			
[[ $PSQLExitCode -eq $UPDATE_AVAILABLE_CODE ]] && yum -y install postgresql-upgrade && postgresql-setup --upgrade || true
postgresql-setup initdb	|| true
sed -E -i "s/(host\s+(all|replication)\s+all\s+(127\.0\.0\.1\/32|\:\:1\/128)\s+)(ident|trust|md5)/\1scram-sha-256/" /var/lib/pgsql/data/pg_hba.conf
sed -i "s/^#\?password_encryption = .*/password_encryption = 'scram-sha-256'/" /var/lib/pgsql/data/postgresql.conf

if ! command -v semanage &> /dev/null; then
	yum install -y policycoreutils-python || yum install -y policycoreutils-python-utils
fi 
semanage permissive -a httpd_t

package_services="rabbitmq-server postgresql ${REDIS_PACKAGE} mysqld elasticsearch"
