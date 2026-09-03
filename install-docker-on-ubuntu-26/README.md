# Install Docker on Ubuntu 26.04

[![Ubuntu](https://img.shields.io/badge/Ubuntu-26.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Docker](https://img.shields.io/badge/Docker-CE-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Ansible](https://img.shields.io/badge/Ansible-5.x-1A1918?style=for-the-badge&logo=ansible&logoColor=white)](https://ansible.com)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

> **Ansible playbook to install Docker CE on Ubuntu 26.04 with security hardening and best practices**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [License](#license)

---

## 🚀 Overview

This repository contains a single Ansible playbook to install Docker CE on Ubuntu 26.04 servers with production-ready configurations including:

- ✅ Official Docker repository setup
- ✅ GPG key management
- ✅ Security hardening
- ✅ Log rotation
- ✅ Auto-verification
- ✅ User group management

---

## 📋 Prerequisites

### Control Node
- Ansible 2.9+
- Python 3.6+
- SSH access to target servers

### Target Hosts
- Ubuntu 26.04 (also works on 22.04/24.04)
- `sudo` privileges
- Internet access

---

## ⚡ Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/install-docker-on-ubuntu-26.git
cd install-docker-on-ubuntu-26
```

### 2. Create Inventory File

```bash
echo "192.168.1.100 ansible_user=ubuntu" > inventory
```

### 3. Run the Playbook

```bash
ansible-playbook -i inventory install-docker.yml
```

### 4. Verify Installation

```bash
docker version
docker run hello-world
```

---

## 💻 Usage Examples

### Single Server

```bash
ansible-playbook -i "192.168.1.100," install-docker.yml -u ubuntu
```

### Multiple Servers

Create `inventory.yml`:

```yaml
all:
  hosts:
    server-01:
      ansible_host: 192.168.1.100
      ansible_user: ubuntu
    server-02:
      ansible_host: 192.168.1.101
      ansible_user: ubuntu
```

Run:

```bash
ansible-playbook -i inventory.yml install-docker.yml
```

### Dry Run

```bash
ansible-playbook -i inventory install-docker.yml --check
```

---

## ⚙️ Configuration

You can override variables at runtime:

```bash
# Change log rotation settings
ansible-playbook -i inventory install-docker.yml \
  -e "docker_log_max_size=20m docker_log_max_files=5"

# Install specific Docker version
ansible-playbook -i inventory install-docker.yml \
  -e "docker_packages=['docker-ce=5:24.0.0-1~ubuntu']"
```

### Default daemon.json Configuration

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Permission denied | Add user to docker group: `sudo usermod -aG docker $USER` and logout/login |
| GPG key fails | Check network connectivity to download.docker.com |
| Docker daemon won't start | Check logs: `journalctl -u docker` |
| Repository not found | Verify Ubuntu codename: `lsb_release -cs` |

### Debug Mode

```bash
ansible-playbook -i inventory install-docker.yml -vvv
```

---

## ❓ FAQ

**Q: Which Docker package should I install?**  
A: Install `docker-ce`. `docker.io` is Ubuntu's outdated package.

**Q: Do I need to reboot?**  
A: Usually no, unless kernel was upgraded. The playbook handles this automatically.

**Q: Can I run this on older Ubuntu?**  
A: Yes, works on Ubuntu 22.04 and 24.04.

**Q: How do I uninstall Docker?**  
A:
```bash
sudo apt purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt autoremove --purge
sudo rm -rf /var/lib/docker /var/lib/containerd
```

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🙏 Acknowledgments

- [Docker](https://docker.com)
- [Ansible](https://ansible.com)
- [Ubuntu](https://ubuntu.com)

---

**Happy Containerizing! 🐳**
