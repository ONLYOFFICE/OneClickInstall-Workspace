## Project Overview

ONLYOFFICE OneClickInstall-Workspace — one-click installer scripts for ONLYOFFICE Workspace (Docs, Mail, CRM, Projects, Calendar) supporting Docker (recommended) and native Linux package (DEB/RPM) deployment.

## Tech Stack

Bash/Shell, Docker, MySQL 5.5, Elasticsearch 7.16.3, Mono/.NET, Redis, RabbitMQ, Vagrant (testing), GitHub Actions

## Project Structure

```
workspace-install.sh              — Workspace Edition entry point
workspace-enterprise-install.sh   — Enterprise Edition entry point
groups-install.sh                 — Groups (Community Server) entry point
install.sh                        — Main Docker installer (2444 lines)
install-Debian.sh                 — Debian package installer wrapper
install-RedHat.sh                 — RedHat package installer wrapper
install-Debian/                   — Debian-specific scripts
  bootstrap.sh                    — System bootstrap
  install-preq.sh                 — Prerequisites (APT)
  install-app.sh                  — App installation
  check-ports.sh                  — Port availability checks
  tools.sh                        — Utility functions, hardware checks
install-RedHat/                   — RedHat-specific scripts
  bootstrap.sh                    — System bootstrap
  install-preq.sh                 — Prerequisites (YUM)
  install-app.sh                  — App installation
  check-ports.sh                  — Port availability checks
  tools.sh                        — Utility functions, hardware checks
tests/vagrant/                    — Vagrant multi-OS test infrastructure
```

## Usage

```bash
# Download and run (Workspace Edition)
curl -O https://download.onlyoffice.com/install/workspace-install.sh
sudo bash workspace-install.sh

# Key flags
--installationtype    WORKSPACE|WORKSPACE_ENTERPRISE|GROUPS
--update              true|false
--communityport       <PORT>     (default: 80)
--skiphardwarecheck   true|false
--jwtenabled          true|false
--jwtsecret           <SECRET>
--maildomain          <DOMAIN>
--installcs           true|false|pull   (Community Server)
--installdocs         true|false|pull   (Document Server)
--installmailserver   true|false|pull   (Mail Server)
--makeswap            true|false        (default: true)
```

## Docker Services

```
onlyoffice-community-server     — Main app (CRM, Projects, Calendar, Portal)
onlyoffice-document-server      — Document editors (Docs, Sheets, Slides)
onlyoffice-mail-server          — Mail server
onlyoffice-control-panel        — Admin control panel
onlyoffice-mysql-server          — MySQL database
onlyoffice-elasticsearch         — Search and indexing
```

## Testing

```bash
# Vagrant-based multi-OS testing
cd tests/vagrant
TEST_CASE='--local-install' OS='base-ubuntu2204' vagrant up

# Docker installation test
sudo bash install.sh --skiphardwarecheck true
```

Supported OS: RHEL 9, CentOS 8/9 Stream, Debian 10-12, Ubuntu 20.04/22.04/24.04

## Key Patterns

- Entry point scripts (`workspace-install.sh`, etc.) route to `install.sh` for Docker or `install-{Debian,RedHat}.sh` for packages
- `install.sh` manages full Docker lifecycle: network creation, volume management, container orchestration
- Custom overlay network `onlyoffice` for inter-service communication
- Hardware checks: 4 CPU cores, 8GB RAM, 40GB disk, 6GB swap minimum
- Three editions: Workspace, Workspace Enterprise, Groups
- JWT auto-generation if secret not provided
- Supports external MySQL, Elasticsearch, Document Server, Mail Server

## Review Focus

**Shell**: POSIX compatibility, quoting, `set -e`, error handling, root checks
**Security**: MySQL root password handling, JWT secret generation, machine key encryption
**Docker**: Container orchestration logic, volume persistence, network management
**Portability**: Multi-distro support (Debian/RedHat), version-specific workarounds
**Idempotency**: Install/update scripts must be safe to re-run
**Config**: Default credentials, exposed ports, service dependencies

## Git Workflow

- **Main branch**: `master`
- **Integration branch**: `develop`
- **Branch naming**: `feature/*`, `bugfix/*`, `hotfix/*`, `release/*`
