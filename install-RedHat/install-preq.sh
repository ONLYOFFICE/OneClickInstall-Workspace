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
	read_unsupported_installation
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
	DOTNET_HOST="dotnet-host-7.0*"
fi

#Add repositories: EPEL, REMI and RPMFUSION
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-$REV.noarch.rpm || true
rpm -ivh http://rpms.remirepo.net/enterprise/remi-release-$REV.rpm || true
yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$REV.noarch.rpm

if [ "$REV" = "9" ]; then
	hyperfastcgi_version=${hyperfastcgi_version:-"0.4-8"};
	MONOREV="8"
	[ $DIST != "redhat" ] && TESTING_REPO="--enablerepo=crb" || /usr/bin/crb enable
	update-crypto-policies --set DEFAULT:SHA1
elif [ "$REV" = "8" ]; then
	hyperfastcgi_version=${hyperfastcgi_version:-"0.4-7"};
	[ $DIST != "redhat" ] && POWERTOOLS_REPO="--enablerepo=powertools" || /usr/bin/crb enable
elif [ "$REV" = "7" ] ; then
	hyperfastcgi_version=${hyperfastcgi_version:-"0.4-6"};
fi

#add rabbitmq & erlang repo
if [ "$MONOREV" -gt "7" ]; then
	curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | os=centos dist=$REV bash
	curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | os=centos dist=$REV bash
else
	cat > /etc/yum.repos.d/rabbitmq_rabbitmq-server.repo <<END
[rabbitmq_rabbitmq-server]
name=rabbitmq_rabbitmq-server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/7/\$basearch
gpgcheck=0
enabled=1
END
	cat > /etc/yum.repos.d/rabbitmq_erlang.repo <<END
[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://packagecloud.io/rabbitmq/erlang/el/7/\$basearch
gpgcheck=0
enabled=1
END
fi

if rpm -q rabbitmq-server; then
	if [ "$(yum list installed rabbitmq-server | awk '/rabbitmq-server/ {gsub(/@/, "", $NF); print $NF}')" != "$(repoquery rabbitmq-server --qf='%{ui_from_repo}' | tail -n 1)" ]; then
		res_rabbitmq_update
		echo $RES_RABBITMQ_VERSION
		echo $RES_RABBITMQ_REMINDER
		echo $RES_RABBITMQ_INSTALLATION
		read_rabbitmq_update
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
MYSQL_REPO_VERSION="$(curl https://repo.mysql.com | grep -oP "mysql80-community-release-el${REV}-\K.*" | grep -o '^[^.]*' | sort | tail -n1)"
yum localinstall -y https://repo.mysql.com/mysql80-community-release-el${REV}-${MYSQL_REPO_VERSION}.noarch.rpm || true

#add mono repo
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
su -c "curl https://download.mono-project.com/repo/centos$MONOREV-stable.repo | tee /etc/yum.repos.d/mono-centos$MONOREV-stable.repo"

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
yum install -y https://rpm.nodesource.com/pub_16.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm

if ! rpm -q mysql-community-server; then
	MYSQL_FIRST_TIME_INSTALL="true";
elif rpm -q mysql-community-server && [ "$UPDATE" = "true" ]; then
	rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
fi

yum -y install python3-dnf-plugin-versionlock || yum -y install yum-plugin-versionlock
yum versionlock clear
yum -y install python36 || true

yum -y install epel-release \
			python3 \
			expect \
			nano \
			htop \
			postgresql \
			postgresql-server \
			rabbitmq-server \
			redis --enablerepo=remi \
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
			snapd \
			nodejs \
			dotnet-sdk-7.0 $DOTNET_HOST
			
yum versionlock mono-complete

systemctl enable --now snapd.socket
ln -fs /var/lib/snapd/snap /snap
systemctl start --now snapd.socket
snap wait system seed

#Fixing permissions selinux to install certbot
cat << EOF > snap_permissions.te
module snap_permissions 1.0;
require {
	type systemd_unit_file_t;
	type init_t;
	type snappy_t;
	type syslogd_var_run_t;
	type journalctl_t;
	type snappy_cli_t;
	class dbus send_msg;
	class service start;
	class system status;
	class dir search;
	class capability sys_resource;
	class file map;
}
allow init_t snappy_cli_t:dbus send_msg;
allow journalctl_t init_t:dir search;
allow journalctl_t self:capability sys_resource;
allow journalctl_t syslogd_var_run_t:file map;
allow snappy_cli_t init_t:dbus send_msg;
allow snappy_cli_t init_t:service start;
allow snappy_cli_t systemd_unit_file_t:service start;
allow snappy_t init_t:system status;
EOF
checkmodule -M -m -o snap_permissions.mod snap_permissions.te && rm snap_permissions.te
semodule_package -o snap_permissions.pp -m snap_permissions.mod && rm snap_permissions.mod
semodule -i snap_permissions.pp && rm snap_permissions.pp

snap install --classic certbot

if ! command -v certbot &> /dev/null; then
	ln -s /snap/bin/certbot /usr/bin/certbot
fi

if ! command -v god &> /dev/null; then
	gem install --bindir /usr/bin god --no-document
fi

if rpm -q ffmpeg2; then
	yum -y remove ffmpeg2	
fi

yum -y install ffmpeg ffmpeg-devel $TESTING_REPO
			
py3_version=$(python3 -c 'import sys; print(sys.version_info.minor)')
if [[ $py3_version -lt 6 ]]; then
	curl -O https://bootstrap.pypa.io/pip/3.$py3_version/get-pip.py
else
	curl -O https://bootstrap.pypa.io/get-pip.py
fi
python3 get-pip.py || true
rm get-pip.py
			
if [[ $PSQLExitCode -eq $UPDATE_AVAILABLE_CODE ]]; then
	yum -y install postgresql-upgrade
	postgresql-setup --upgrade || true
fi

postgresql-setup initdb	|| true

if [ -z $ELASTICSEARCH_REPOSITORY ]; then
	rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat > /etc/yum.repos.d/elasticsearch.repo <<END
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
END
fi

if ! rpm -q elasticsearch; then
	yum install -y elasticsearch-7.16.3-1
fi

if ! command -v semanage &> /dev/null; then
	yum install -y policycoreutils-python-utils
fi 

semanage permissive -a httpd_t

package_services="rabbitmq-server postgresql redis mysqld elasticsearch"
