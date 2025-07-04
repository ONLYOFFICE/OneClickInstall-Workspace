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

| Flag                  | Value placeholder                                 | Description                           |
|-----------------------|---------------------------------------------------|---------------------------------------|
| `--installationtype`  | `GROUPS` \| `WORKSPACE` \| `WORKSPACE_ENTERPRISE` | Choose edition                        |
| `--update`            | `true` \| `false`                                 | Update existing containers / packages |
| `--skiphardwarecheck` | `true` \| `false`                                 | Skip CPU/RAM/Disk checks              |

### Docker flags
> Applies only to Docker installation

| Flag                       | Value placeholder            | Description                                    |
|----------------------------|------------------------------|------------------------------------------------|
| `--communityimage`         | `<NAME>` \| `<.tar.gz>`      | Community Server image name or tar.gz path     |
| `--documentimage`          | `<NAME>` \| `<.tar.gz>`      | Document Server image name or tar.gz path      |
| `--mailimage`              | `<NAME>` \| `<.tar.gz>`      | Mail Server image name or tar.gz path          |
| `--elasticsearchimage`     | `<NAME>` \| `<.tar.gz>`      | Elasticsearch image name or tar.gz path        |
| `--controlpanelimage`      | `<NAME>` \| `<.tar.gz>`      | Control Panel image name or tar.gz path        |
| `--mysqlimage`             | `<NAME>` \| `<.tar.gz>`      | MySQL image name or tar.gz path                |
| `--communityversion`       | `<VERSION>`                  | Community Server version                       |
| `--documentversion`        | `<VERSION>`                  | Document Server version                        |
| `--mailversion`            | `<VERSION>`                  | Mail Server version                            |
| `--elasticsearchversion`   | `<VERSION>`                  | Elasticsearch version                          |
| `--controlpanelversion`    | `<VERSION>`                  | Control Panel version                          |
| `--documentserverip`       | `<IP>`                       | Document Server container IP                   |
| `--elasticsearchhost`      | `<HOST>`                     | Elasticsearch host                             |
| `--elasticsearchport`      | `<PORT>`                     | Elasticsearch port                             |
| `--mailserverip`           | `<IP>`                       | Mail Server container IP                       |
| `--mailserverdbip`         | `<IP>`                       | Mail Server DB IP                              |
| `--hub`                    | `<DOMAIN>`                   | DockerHub name (or registry domain)            |
| `--username`               | `<USER>`                     | DockerHub username                             |
| `--password`               | `<PASS>`                     | DockerHub password                             |
| `--installcommunityserver` | `true` \| `false` \| `pull`  | Install / skip / pre-pull Community Server     |
| `--installdocumentserver`  | `true` \| `false` \| `pull`  | Install / skip / pre-pull Document Server      |
| `--installmailserver`      | `true` \| `false` \| `pull`  | Install / skip / pre-pull Mail Server          |
| `--installelasticsearch`   | `true` \| `false` \| `pull`  | Install / skip / pre-pull Elasticsearch        |
| `--installcontrolpanel`    | `true` \| `false` \| `pull`  | Install / skip / pre-pull Control Panel        |
| `--useasexternalserver`    | `true` \| `false`            | Expose services externally                     |
| `--partnerdatafile`        | `<FILE>`                     | Partner data file path                         |
| `--makeswap`               | `true` \| `false`            | Auto-create swap file                          |
| `--communityport`          | `<PORT>` (80)                | Community Server HTTP port                     |
| `--mysqlhost`              | `<HOST>`                     | MySQL host                                     |
| `--mysqlport`              | `<PORT>`                     | MySQL port                                     |
| `--mysqlrootuser`          | `<USER>`                     | MySQL root user                                |
| `--mysqlrootpassword`      | `<PASSWORD>`                 | MySQL root password                            |
| `--mysqldatabase`          | `<DB>`                       | Community Server database name                 |
| `--mysqluser`              | `<USER>`                     | Community Server DB user                       |
| `--mysqlpassword`          | `<PASSWORD>`                 | Community Server DB user password              |
| `--mysqlmaildatabase`      | `<DB>`                       | Mail Server database name                      |
| `--mysqlmailuser`          | `<USER>`                     | Mail Server DB user                            |
| `--mysqlmailpassword`      | `<PASSWORD>`                 | Mail Server DB user password                   |
| `--skipversioncheck`       | `true` \| `false`            | Skip version check during update               |
| `--skipdomaincheck`        | `true` \| `false`            | Skip domain check when installing mail server  |
| `--machinekey`             | `<KEY>`                      | core.machinekey setting                        |
| `--jwtenabled`             | `true` \| `false`            | Enable JWT validation                          |
| `--jwtheader`              | `<HEADER>`                   | JWT HTTP header name                           |
| `--jwtsecret`              | `<SECRET>`                   | JWT secret key                                 |

### Package-specific flags
> Applies only to package installation

| Flag             | Value placeholder | Description       |
|------------------|-------------------|-------------------|
| `--localscripts` | `true` \| `false` | Run local scripts |

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
