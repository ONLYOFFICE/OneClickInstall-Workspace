[![License](https://img.shields.io/badge/License-GNU%20AGPL%20V3-green.svg?style=flat)](https://www.gnu.org/licenses/agpl-3.0.en.html)
[![Docker Pulls](https://img.shields.io/docker/pulls/onlyoffice/communityserver?logo=docker)](https://hub.docker.com/r/onlyoffice/communityserver)
[![Docker Image Version](https://img.shields.io/docker/v/onlyoffice/communityserver?sort=semver&logo=docker)](https://hub.docker.com/r/onlyoffice/communityserver/tags)
[![GitHub Stars](https://img.shields.io/github/stars/ONLYOFFICE/OneClickInstall-Workspace?style=flat&logo=github)](https://github.com/ONLYOFFICE/OneClickInstall-Workspace/stargazers)

# ONLYOFFICE Workspace - OneClickInstall

A simple self-hosted installer for **ONLYOFFICE Workspace** using Docker or Linux packages.

| 🚀 [Start](#-quick-start) | 🛠 [Flags](#-flags) | 💡 [Examples](#-examples) | 🖥️ [Reqs](#-system-requirements) | ✅ [OS](#-supported-operating-systems) | 📚 [Resources](#-additional-resources) | 📝 [License](#-license) |
|--------------------------|--------------------------------------------|---------------------------|----------------------------------------|----------------------------------------|----------------------------------------|----------------------|

**ONLYOFFICE Workspace** is a bundle of web apps for team management and collaboration, including:

- 📝 **Docs** - powerful collaborative editors
- 📧 **Mail** - secure mail server
- 📊 **CRM** - customer relationship management
- 📁 **Projects** - tasks and milestones tracking
- 📅 **Calendar** - event scheduling and reminders

Supports all popular office formats:
**DOCX, XLSX, PPTX, ODT, PDF, CSV, TXT, HTML, EPUB**,  
and combines them with collaboration tools for tasks, projects, and team communication - all in one secure platform.

## 🚀 Quick Start

### 1. Download the installer

Community Edition (default):

```bash
curl -O https://download.onlyoffice.com/workspace/workspace-install.sh
```

If you want to install a different edition, choose one of the following:

> **Enterprise Edition**
> ```bash
> curl -O https://download.onlyoffice.com/workspace/workspace-enterprise-install.sh
> ```

> **Groups** (Community Server only)
> ```bash
> curl -O https://download.onlyoffice.com/workspace/groups-install.sh
> ```

### 2. Run the script

The script detects your OS and installs ONLYOFFICE Workspace using Docker (or native packages, if selected).  

```bash
sudo bash workspace-install.sh
```

> **Enterprise Edition**
> ```bash
> sudo bash workspace-enterprise-install.sh
> ```

> **Groups**
> ```bash
> sudo bash groups-install.sh
> ```

You'll be prompted to choose the installation method:

- `Y` — Docker install (recommended)
- `N` — native `.deb` / `.rpm` packages

## 🛠 Flags

All scripts support `--help` to show available flags. View available options with:
```bash
sudo bash workspace-install.sh --help
```
### Common flags
> Works for both Docker and package installations

| Flag                  | Value placeholder                             | Default value            | Description  |
|-----------------------|-----------------------------------------------|--------------------------|--------------|
| `--installationtype`  | `GROUPS`\|`WORKSPACE`\|`WORKSPACE_ENTERPRISE` | `WORKSPACE_ENTERPRISE`   | Edition      |
| `--update`            | `true` \| `false`                             | `false`                  | Update       |
| `--skiphardwarecheck` | `true` \| `false`                             | `false`                  | Skip checks  |

### Docker flags
> Applies only to Docker installation

| Flag                       | Value placeholder            | Default value                  | Description             |
|----------------------------|------------------------------|--------------------------------|-------------------------|
| `--communityimage`         | `<NAME>` \| `<.tar.gz>`      | `onlyoffice/communityserver`   | CS image                |
| `--documentimage`          | `<NAME>` \| `<.tar.gz>`      | `onlyoffice/documentserver-ee` | Docs image              |
| `--mailimage`              | `<NAME>` \| `<.tar.gz>`      | `onlyoffice/mailserver`        | Mail image              |
| `--elasticsearchimage`     | `<NAME>` \| `<.tar.gz>`      | `onlyoffice/elasticsearch`     | ES image                |
| `--controlpanelimage`      | `<NAME>` \| `<.tar.gz>`      | `onlyoffice/controlpanel`      | CP image                |
| `--mysqlimage`             | `<NAME>` \| `<.tar.gz>`      | `mysql`                        | MySQL image             |
| `--communityversion`       | `<VERSION>`                  | *(latest stable)*              | CS version              |
| `--documentversion`        | `<VERSION>`                  | *(latest stable)*              | Docs version            |
| `--mailversion`            | `<VERSION>`                  | *(latest stable)*              | Mail version            |
| `--elasticsearchversion`   | `<VERSION>`                  | `7.16.3`                       | ES version              |
| `--controlpanelversion`    | `<VERSION>`                  | *(latest stable)*              | CP version              |
| `--documentserverip`       | `<IP>`                       | -                              | Docs IP                 |
| `--elasticsearchhost`      | `<HOST>`                     | -                              | ES host                 |
| `--elasticsearchport`      | `<PORT>`                     | `9200`                         | ES port                 |
| `--mailserverip`           | `<IP>`                       | -                              | Mail IP                 |
| `--mailserverdbip`         | `<IP>`                       | -                              | Mail DB IP              |
| `--hub`                    | `<DOMAIN>`                   | -                              | DockerHub domain        |
| `--username`               | `<USER>`                     | -                              | DockerHub user          |
| `--password`               | `<PASS>`                     | -                              | DockerHub password      |
| `--installcs`              | `true` \| `false` \| `pull`  | `true`                         | Install/skip/pull CS    |
| `--installdocs`            | `true` \| `false` \| `pull`  | `true`                         | Install/skip/pull DS    |
| `--installmailserver`      | `true` \| `false` \| `pull`  | `true`                         | Install/skip/pull Mail  |
| `--installelasticsearch`   | `true` \| `false` \| `pull`  | `true`                         | Install/skip/pull ES    |
| `--installcontrolpanel`    | `true` \| `false` \| `pull`  | `true`                         | Install/skip/pull CP    |
| `--useasexternalserver`    | `true` \| `false`            | `false`                        | Expose services         |
| `--partnerdatafile`        | `<FILE>`                     | -                              | Partner data path       |
| `--makeswap`               | `true` \| `false`            | `true`                         | Create swap file        |
| `--communityport`          | `<PORT>`                     | `80`                           | HTTP port for CS        |
| `--mysqlhost`              | `<HOST>`                     | -                              | MySQL host              |
| `--mysqlport`              | `<PORT>`                     | `3306`                         | MySQL port              |
| `--mysqlrootuser`          | `<USER>`                     | `root`                         | MySQL root user         |
| `--mysqlrootpassword`      | `<PASSWORD>`                 | `my-secret-pw`                 | MySQL root password     |
| `--mysqldatabase`          | `<DB>`                       | `onlyoffice`                   | CS database name        |
| `--mysqluser`              | `<USER>`                     | `onlyoffice_user`              | CS database user        |
| `--mysqlpassword`          | `<PASSWORD>`                 | `onlyoffice_pass`              | CS user password        |
| `--mysqlmaildatabase`      | `<DB>`                       | `onlyoffice_mailserver`        | Mail DB name            |
| `--mysqlmailuser`          | `<USER>`                     | `mail_admin`                   | Mail DB user            |
| `--mysqlmailpassword`      | `<PASSWORD>`                 | `Isadmin123`                   | Mail DB password        |
| `--skipversioncheck`       | `true` \| `false`            | `false`                        | Skip version check      |
| `--skipdomaincheck`        | `true` \| `false`            | `false`                        | Skip domain check       |
| `--machinekey`             | `<KEY>`                      | *(auto-generate)*              | machinekey setting      |
| `--jwtenabled`             | `true` \| `false`            | `true`                         | Enable JWT              |
| `--jwtheader`              | `<HEADER>`                   | `AuthorizationJwt`             | JWT header              |
| `--jwtsecret`              | `<SECRET>`                   | *(auto-generate)*              | JWT secret key          |

### Package-specific flags
> Applies only to package installation

| Flag             | Value placeholder | Default value  | Description       |
|------------------|-------------------|----------------|-------------------|
| `--localscripts` | `true` \| `false` | `false`        | Run local scripts |

## 💡 Examples

Typical usage scenarios with different combinations of flags.  

1. Quick install on port 8080
```bash
sudo bash workspace-install.sh --communityport 8080
```

2. Update all components, skip hardware check
```bash
sudo bash workspace-install.sh \
  --update true \
  --skiphardwarecheck true
```

3. Install without Mail Server
```bash
sudo bash workspace-install.sh --installmailserver false
```

4. Document Server only (external)
```bash
sudo bash workspace-install.sh \
  --installcommunityserver false \
  --installdocumentserver true \
  --installcontrolpanel false \
  --installmailserver false \
  --useasexternalserver true
```

5. Update Community Server to specific version
```bash
sudo bash workspace-install.sh \
  --update true \
  --communityversion 12.7.1.1942 \
  --installdocumentserver false \
  --installcontrolpanel false \
  --installmailserver false
```

6. Deploy from private registry
```bash
sudo bash workspace-install.sh \
  --hub reg.example.com:5000 \
  --username USER --password PASS
```

## 🖥 System Requirements

| Resource   | Minimum              |
|------------|----------------------|
| **CPU**    | 4-core               |
| **RAM**    | 8 GB                 |
| **Disk**   | 40 GB+ free          |
| **Swap**   | ≥ 6 GB               |
| **Kernel** | Linux 3.10+ (x86_64) |

\* Minimum requirements for test environments. For production, 8 GB RAM or more is recommended.

## ✅ Supported Operating Systems

The installation scripts support the following operating systems, which are **regularly tested** as part of our CI/CD pipelines:
<!-- OS-SUPPORT-LIST-START -->
- RHEL 9
- CentOS 8 Stream
- CentOS 9 Stream
- Debian 10
- Debian 11
- Debian 12
- Ubuntu 20.04
- Ubuntu 22.04
- Ubuntu 24.04
<!-- OS-SUPPORT-LIST-END -->

## 📚 Additional Resources

| Resource         | Link                                                                  |
|------------------|-----------------------------------------------------------------------|
| Official website | <https://www.onlyoffice.com/>                                         |
| Docs installer   | <https://github.com/ONLYOFFICE/OneClickInstall-Docs>                  |
| Help Center      | <https://helpcenter.onlyoffice.com/workspace/installation>            |
| Product page     | <https://www.onlyoffice.com/workspace.aspx>                           |
| Community Forum  | <https://forum.onlyoffice.com>                                        |
| Stack Overflow   | <https://stackoverflow.com/questions/tagged/onlyoffice>               |

## 📝 License

ONLYOFFICE Workspace is released under the [**GNU AGPL v3**](https://onlyo.co/38YZGJh) license for the Community Edition.  
**Enterprise** and other commercial editions require a valid license key. For more details, please contact [sales@onlyoffice.com](mailto:sales@onlyoffice.com).
