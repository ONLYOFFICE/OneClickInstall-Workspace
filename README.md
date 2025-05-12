## Overview

This repo contains scripts to quickly install ONLYOFFICE Workspace.

ONLYOFFICE Workspace is a bundle of web apps for team management and collaboration.

It has two editions - [Community, Enterprise](#onlyoffice-docs-editions).

`workspace-install.sh` is used to install ONLYOFFICE Workspace Community Edition.

`workspace-enterprise-install.sh` installs ONLYOFFICE Workspace Enterprise Edition.

## [Functionality](https://www.onlyoffice.com/workspace.aspx)

* Documents
* Mails
* CRM
* PROJECTS
* CALENDAR

## Recommended system requirements

* **CPU**: at least 4-core (6-core recommended)
* **RAM**: at least 8 GB (12 GB recommended)
* **HDD**: at least 40 GB of free space
* **Swap file**: at least 6 GB of swap
* **OS**: amd64 Linux distribution with kernel version 3.10 or later

## Supported Operating Systems

The installation scripts support the following operating systems, which are **regularly tested** as part of our CI/CD pipelines:
<!-- OS-SUPPORT-LIST-START -->
- RHEL 9
- CentOS8S
- CentOS9S
- Debian10
- Debian11
- Debian12
- Ubuntu20.04
- Ubuntu22.04
- Ubuntu24.04
<!-- OS-SUPPORT-LIST-END -->

## Installing ONLYOFFICE Workspace using the provided script

**STEP 1**: Download ONLYOFFICE Workspace Community Edition Docker script file:

```bash
wget http://download.onlyoffice.com/install/workspace-install.sh
```

**STEP 2**: Install ONLYOFFICE Workspace executing the following command:

```bash
bash workspace-install.sh
```

The detailed instruction is available in [ONLYOFFICE Help Center](https://helpcenter.onlyoffice.com/installation/workspace-index.aspx). 

To install Enterprise Edition, use [this instruction](https://helpcenter.onlyoffice.com/installation/workspace-enterprise-index.aspx). 

## Project information

Official website: [https://www.onlyoffice.com](https://www.onlyoffice.com/?utm_source=github&utm_medium=cpc&utm_campaign=GitHubDS)

License: [GNU AGPL v3.0](https://onlyo.co/38YZGJh)

ONLYOFFICE Workspace on official website: [http://www.onlyoffice.com/office-suite.aspx](https://www.onlyoffice.com/workspace.aspx)
