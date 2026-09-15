# Ubuntu Server Hardening with Ansible

![Ansible](https://img.shields.io/badge/Ansible-2.15%2B-red?logo=ansible)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-E95420?logo=ubuntu)
![License](https://img.shields.io/badge/License-MIT-blue)
![Maintained](https://img.shields.io/badge/Maintained-yes-green)

A production-ready Ansible playbook that performs **initial server setup and hardening** on fresh Ubuntu Server installations. It automates the exact workflow used by a RHCE, CKA, ISC2 CC, and AWS Engineer with 15+ years of experience managing Linux infrastructure.

---

## Table of Contents

- [Features](#features)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Verification](#verification)
- [What Gets Applied](#what-gets-applied)
- [Customization](#customization)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

---

## Features

- **System Updates** – Refresh apt cache and apply safe upgrades with autoremove/autoclean.
- **Non-Root Admin User** – Create a dedicated `deploy` user with sudo privileges.
- **SSH Key-Based Authentication** – Deploy public keys and disable password auth.
- **SSH Hardening** – Disable root login, X11 forwarding, and set strict auth limits.
- **UFW Firewall** – Default deny incoming, allow outgoing, allow only configured ports.
- **Automatic Security Updates** – Configure `unattended-upgrades` for hands-off patching.
- **Time Synchronization** – Set timezone and enable NTP via `timedatectl`.
- **Essential Packages** – Curated baseline (curl, git, vim, htop, fail2ban, etc.).
- **Fail2Ban** – Ban IPs after repeated failed SSH login attempts.
- **Swap Management** – Create and persist a swap file if none exists.
- **Kernel Hardening** – Apply sysctl parameters for network and kernel security.
- **Logging & Monitoring** – Enable `rsyslog` and deploy `logwatch` daily reports.
- **Backup Strategy** – Simple `/etc`, `/home`, `/var/www` backup script with cron.
- **Idempotent & Validated** – All tasks are idempotent; templates are validated before reload.
- **Handlers** – Service restarts only trigger on actual config changes.

---

## Repository Structure

```
ubuntu-hardening/
├── README.md
├── LICENSE
├── ansible.cfg
├── inventory.ini
├── harden.yml
├── vars/
│   └── main.yml
├── templates/
│   ├── sshd_config.j2
│   ├── jail.local.j2
│   └── 99-hardening.conf.j2
└── secrets.yml          # Optional (encrypted with ansible-vault)
```

---

## Prerequisites

### Control Node (where you run Ansible)

- Ansible **2.15+** installed
  ```bash
  sudo apt install ansible
  # or
  pip install ansible
  ```
- Required collections:
  ```bash
  ansible-galaxy collection install community.general ansible.posix
  ```
- SSH key pair (Ed25519 recommended):
  ```bash
  ssh-keygen -t ed25519 -C "you@example.com"
  ```

### Managed Nodes (target Ubuntu servers)

- Ubuntu Server **22.04 LTS** or **24.04 LTS**
- SSH access as a user with sudo privileges
- Python 3 installed (default on modern Ubuntu)
- Passwordless sudo **recommended** (or use `--ask-become-pass`)

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-username/ubuntu-hardening.git
cd ubuntu-hardening

# 2. Install required Ansible collections
ansible-galaxy collection install community.general ansible.posix

# 3. Edit inventory with your server details
vim inventory.ini

# 4. Test connectivity
ansible -i inventory.ini ubuntu_servers -m ping

# 5. Syntax check
ansible-playbook -i inventory.ini harden.yml --syntax-check

# 6. Dry run (recommended before applying)
ansible-playbook -i inventory.ini harden.yml --check --diff

# 7. Apply hardening
ansible-playbook -i inventory.ini harden.yml
```

---

## Configuration

### Inventory (`inventory.ini`)

Define your target hosts and connection variables:

```ini
[ubuntu_servers]
server1 ansible_host=192.168.1.100

[ubuntu_servers:vars]
ansible_user=deploy
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_python_interpreter=/usr/bin/python3
ansible_become=true
```

See the file for multi-environment examples (dev/staging/prod).

### Variables (`vars/main.yml`)

All tunable settings live in `vars/main.yml`:

| Variable | Default | Description |
|---|---|---|
| `admin_user` | `deploy` | Non-root sudo user to create |
| `ssh_port` | `22` | SSH port |
| `ssh_permit_root_login` | `no` | Disable direct root SSH |
| `ssh_password_auth` | `no` | Disable password auth |
| `ufw_allowed_ports` | `[{22/tcp}]` | Ports to open in UFW |
| `fail2ban_bantime` | `3600` | Ban duration (seconds) |
| `swap_file_size_mb` | `2048` | Swap file size |
| `system_timezone` | `Asia/Karachi` | Server timezone |
| `essential_packages` | (list) | Baseline packages to install |

Override any variable at runtime:

```bash
ansible-playbook -i inventory.ini harden.yml -e "admin_user=sysadmin swap_file_size_mb=4096"
```

### Ansible Vault (Optional)

If your sudo requires a password, encrypt it:

```bash
ansible-vault create secrets.yml
```

Add:

```yaml
vault_sudo_password: "YourSudoPassword"
```

Then reference in `harden.yml`:

```yaml
vars_files:
  - vars/main.yml
  - secrets.yml
```

Run with:

```bash
ansible-playbook -i inventory.ini harden.yml --ask-vault-pass
```

---

## Usage

### Check Mode (Dry Run)

Always run in check mode first to preview changes:

```bash
ansible-playbook -i inventory.ini harden.yml --check --diff
```

### Apply to All Hosts

```bash
ansible-playbook -i inventory.ini harden.yml
```

### Apply to a Specific Host

```bash
ansible-playbook -i inventory.ini harden.yml --limit server1
```

### Apply to a Specific Group

```bash
ansible-playbook -i inventory.ini harden.yml --limit prod
```

### Apply with Tags

Only run specific sections (add tags to tasks as needed):

```bash
ansible-playbook -i inventory.ini harden.yml --tags "ssh,ufw"
```

### Verbose Output

```bash
ansible-playbook -i inventory.ini harden.yml -vvv
```

---

## Verification

After running the playbook, verify the hardening on each server:

```bash
# SSH syntax
sudo sshd -t

# SSH service status
sudo systemctl status ssh

# Firewall status
sudo ufw status verbose

# Fail2ban status
sudo fail2ban-client status sshd

# Swap
sudo swapon --show
free -h

# Time synchronization
timedatectl status

# Sysctl hardening
sudo sysctl -a | grep -E "rp_filter|accept_redirects|syncookies"

# Services
systemctl status ssh fail2ban rsyslog unattended-upgrades

# Backup cron
sudo crontab -l
ls -lh /backups/
```

Or use the ad-hoc command to verify all hosts:

```bash
ansible -i inventory.ini ubuntu_servers -m shell -a "sudo ufw status | head -n 5"
```

---

## What Gets Applied

| # | Step | Purpose |
|---|---|---|
| 1 | System update & upgrade | Latest security patches |
| 2 | Non-root admin user | Principle of least privilege |
| 3 | SSH key deployment | Passwordless, secure access |
| 4 | SSH hardening | Disable root, password auth |
| 5 | UFW firewall | Network access control |
| 6 | Unattended upgrades | Automatic patching |
| 7 | Time synchronization | Consistent logs and certs |
| 8 | Essential packages | Baseline tooling |
| 9 | Fail2Ban | Brute-force protection |
| 10 | Swap file | Memory safety net |
| 11 | Kernel hardening | Network/kernel security |
| 12 | Logging & monitoring | Visibility into server events |
| 13 | Backup strategy | Data protection |

---

## Customization

### Enable IPv6

Edit `templates/99-hardening.conf.j2` and remove:

```
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

### Allow ICMP Ping

Edit the same file and set:

```
net.ipv4.icmp_echo_ignore_all = 0
```

### Change SSH Port

Update `ssh_port` in `vars/main.yml` and add the new port to `ufw_allowed_ports`.

### Add More UFW Rules

Append to `ufw_allowed_ports` in `vars/main.yml`:

```yaml
ufw_allowed_ports:
  - { port: "22",  proto: "tcp", comment: "SSH" }
  - { port: "80",  proto: "tcp", comment: "HTTP" }
  - { port: "443", proto: "tcp", comment: "HTTPS" }
```

### Use a Different Admin User

```bash
ansible-playbook -i inventory.ini harden.yml -e "admin_user=sysadmin"
```

---

## Security Considerations

- **Test in staging first.** Never apply to production without a dry run.
- **Backup your SSH keys.** Losing them can lock you out.
- **Keep console access.** Cloud providers offer VNC/serial console for recovery.
- **Do not disable ICMP** if you rely on ping-based monitoring.
- **Do not disable IPv6** unless you are certain it is unused.
- **Rotate SSH keys** periodically and audit `authorized_keys`.
- **Fail2Ban is not a silver bullet.** Combine with key-based auth and firewalls.
- **Review `unattended-upgrades` logs** for failed patches.
- **Monitor `/var/log/auth.log`** for suspicious login attempts.

---

## Troubleshooting

### SSH Lockout

If the playbook disables password auth before your key is deployed, you may be locked out. Use your cloud provider's console to:

```bash
sudo nano /etc/ssh/sshd_config
# Set PasswordAuthentication yes temporarily
sudo systemctl restart ssh
```

Then redeploy the SSH key and re-run the playbook.

### Fail2Ban Fails to Start

Check the configuration syntax:

```bash
sudo fail2ban-client -t
sudo journalctl -u fail2ban -n 50
```

### UFW Blocks Required Ports

Add the port to `ufw_allowed_ports` in `vars/main.yml` and re-run:

```bash
sudo ufw allow <port>/tcp
```

### Swap File Already Exists

The playbook skips swap creation if `/swapfile` exists. To resize:

```bash
sudo swapoff /swapfile
sudo rm /swapfile
# Then re-run the playbook
```

### Ansible Python Interpreter Warning

Set in `inventory.ini` or `ansible.cfg`:

```ini
ansible_python_interpreter=/usr/bin/python3
```

### Vault Password Prompt

Use a password file to avoid typing:

```bash
echo "your-vault-password" > ~/.vault_pass
chmod 600 ~/.vault_pass
ansible-playbook -i inventory.ini harden.yml --vault-password-file ~/.vault_pass
```

---

## Contributing

Contributions are welcome. Please:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/my-improvement`).
3. Test on a fresh Ubuntu VM or container.
4. Submit a pull request with a clear description.

Please ensure all tasks remain idempotent and pass `--check --diff`.

---

## Author

**Your Name**
RHCE | CKA | ISC2 CC | AWS Engineer
15+ years of Linux and cloud infrastructure experience.

- GitHub: [@your-username](https://github.com/alaricbird)
- Blog: [your-blog.example.com](https://centlinux.com)

---

## References

- [Ubuntu Documentation](https://docs.ubuntu.com/)
- [Ansible Documentation](https://docs.ansible.com/)
- [RHEL Documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10)
- [MongoDB Documentation](https://www.mongodb.com/docs/)
- [OpenSSH Manual](https://www.openssh.com/manual.html)
- [Fail2Ban Documentation](https://github.com/fail2ban/fail2ban)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)

---

## Star History

If this project helped you, please consider giving it a star. It helps others find it.

⭐ **[Star this repository](https://github.com/alaricbird/centlinux/new/main/ubuntu-initial-server-setup)**
