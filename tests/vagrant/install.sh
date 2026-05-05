#!/bin/bash

set -e

while [ "$1" != "" ]; do
  case $1 in
    -ds  | --download-scripts  ) [ -n "$2" ] && DOWNLOAD_SCRIPTS="$2"   && shift ;;
    -arg | --arguments         ) [ -n "$2" ] && ARGUMENTS="$2"          && shift ;;
    -pi  | --production-install) [ -n "$2" ] && PRODUCTION_INSTALL="$2" && shift ;;
    -li  | --local-install     ) [ -n "$2" ] && LOCAL_INSTALL="$2"      && shift ;;
    -lu  | --local-update      ) [ -n "$2" ] && LOCAL_UPDATE="$2"       && shift ;;
    -tr  | --test-repo         ) [ -n "$2" ] && TEST_REPO_ENABLE="$2"   && shift ;;
  esac
  shift
done

export TERM=xterm-256color


get_colors() {
  export LINE_SEPARATOR="-----------------------------------------"
  export COLOR_BLUE=$'\e[34m' COLOR_GREEN=$'\e[32m' COLOR_RED=$'\e[31m' COLOR_RESET=$'\e[0m' COLOR_YELLOW=$'\e[33m'
}

check_hw() {
  echo "${COLOR_RED} $(free -h) ${COLOR_RESET}"
  echo "${COLOR_RED} $(nproc) ${COLOR_RESET}"
}

add_repo_deb() {
  mkdir -p "$HOME"/.gnupg && chmod 700 "$HOME"/.gnupg
  echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] http://static.teamlab.info.s3.amazonaws.com/repo/4testing/debian stable main" | \
    tee /etc/apt/sources.list.d/onlyoffice4testing.list
  curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | \
    gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/onlyoffice.gpg --import
  chmod 644 /usr/share/keyrings/onlyoffice.gpg
}

add_repo_rpm() {
  cat > /etc/yum.repos.d/onlyoffice4testing.repo <<END
[onlyoffice4testing]
name=onlyoffice4testing repo
baseurl=http://static.teamlab.info.s3.amazonaws.com/repo/4testing/centos/main/noarch/
gpgcheck=1
gpgkey=https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE
enabled=1
END
}

prepare_vm() {
  if ! command -v curl >/dev/null 2>&1; then
    (command -v apt-get >/dev/null 2>&1 && apt-get update -y && apt-get install -y curl) || (command -v dnf >/dev/null 2>&1 && dnf install -y curl)
  fi
  if ! command -v gpg >/dev/null 2>&1; then
    (command -v apt-get >/dev/null 2>&1 && apt-get update -y && apt-get install -y gnupg) || (command -v dnf >/dev/null 2>&1 && dnf install -y gnupg2)
  fi

  [ -f /etc/os-release ] && source /etc/os-release || { echo "${COLOR_RED}File /etc/os-release doesn't exist${COLOR_RESET}"; exit 1; }

  case $ID in
    ubuntu|debian)
      systemctl mask --now apt-daily.service apt-daily-upgrade.service apt-daily.timer apt-daily-upgrade.timer unattended-upgrades 2>/dev/null || true
      if [[ "$ID" == "debian" ]] && dpkg -s postfix &>/dev/null; then
        apt-get remove -y postfix && echo "${COLOR_GREEN}[OK] PREPARE_VM: Postfix was removed${COLOR_RESET}"
      fi
      [[ "${TEST_REPO_ENABLE}" == 'true' ]] && add_repo_deb
      ;;

    centos|rhel)
      local REV="${VERSION_ID%%.*}"
      if [[ "$REV" == "9" ]]; then
        update-crypto-policies --set LEGACY
        echo "${COLOR_GREEN}[OK] PREPARE_VM: sha1 gpg key check enabled${COLOR_RESET}"
        cat <<'EOF' | sudo tee /etc/yum.repos.d/centos-stream-9.repo
[centos9s-baseos]
name=CentOS Stream 9 - BaseOS
baseurl=http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/
enabled=1
gpgcheck=0

[centos9s-appstream]
name=CentOS Stream 9 - AppStream
baseurl=http://mirror.stream.centos.org/9-stream/AppStream/x86_64/os/
enabled=1
gpgcheck=0
EOF
      elif [[ "$ID" == "centos" && "$REV" == "8" ]]; then
        sudo sed -i 's|^mirrorlist=|#&|; s|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' /etc/yum.repos.d/CentOS-*
      fi
      [[ "${TEST_REPO_ENABLE}" == 'true' ]] && add_repo_rpm
      ;;

    *)
      echo "${COLOR_RED}Failed to determine Linux dist${COLOR_RESET}"; exit 1
      ;;
  esac

  rm -rf /home/vagrant/*
  [ -d /tmp/workspace ] && mv /tmp/workspace/* /home/vagrant

  echo '127.0.0.1 host4test' | sudo tee -a /etc/hosts
  echo "${COLOR_GREEN}[OK] PREPARE_VM: Hostname was setting up${COLOR_RESET}"
}

install_workspace() {
  if [ "${DOWNLOAD_SCRIPTS}" == 'true' ]; then
    curl -fLO https://download.onlyoffice.com/install/workspace-install.sh
  else
    sed 's/set -e/set -xe/' -i *.sh
  fi
  printf "N\nY\nY" | bash workspace-install.sh ${ARGUMENTS} || { echo "Exit code non-zero. Exit with 1."; exit 1; }
}


main() {
  get_colors

  echo "${COLOR_BLUE}${LINE_SEPARATOR}${COLOR_RESET}"
  echo "${COLOR_BLUE}STEP 1: Preparing VM environment${COLOR_RESET}"
  echo "${COLOR_BLUE}${LINE_SEPARATOR}${COLOR_RESET}"
  prepare_vm

  echo "${COLOR_BLUE}${LINE_SEPARATOR}${COLOR_RESET}"
  echo "${COLOR_BLUE}STEP 2: Checking hardware${COLOR_RESET}"
  echo "${COLOR_BLUE}${LINE_SEPARATOR}${COLOR_RESET}"
  check_hw

  echo "${COLOR_BLUE}${LINE_SEPARATOR}${COLOR_RESET}"
  echo "${COLOR_BLUE}STEP 3: Installing${COLOR_RESET}"
  echo "${COLOR_BLUE}${LINE_SEPARATOR}${COLOR_RESET}"
  install_workspace

  install -m 755 -D /tmp/post-install.sh /home/vagrant/tests/vagrant/post-install.sh 2>/dev/null || true
}

main
