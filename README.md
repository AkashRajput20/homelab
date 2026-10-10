# Homelab: hardened Ubuntu server

A home server on an old laptop, set up and secured by hand. It's the first project in my move from system administration to DevOps.

## What it does
- SSH access with keys only: password and root logins are off
- Firewall (ufw) blocks all incoming traffic except SSH and HTTP
- Serves a website with Nginx
- Installs security updates automatically
- Backs up /etc every night with a Bash script and cron, keeping 7 days
- Keeps running with the laptop lid closed

## Setup

### SSH hardening
[config/ssh/00-hardening.conf](config/ssh/00-hardening.conf) turns off password and root logins. Files in `sshd_config.d/` load before the main config, and the first value wins, so the `00-` prefix makes these settings apply.

```bash
sudo sshd -t && sudo systemctl restart ssh
sudo sshd -T | grep -Ei 'passwordauthentication|permitrootlogin'
```

### Firewall

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx HTTP'
sudo ufw enable
```

### Nightly backups
[scripts/homelab-backup.sh](scripts/homelab-backup.sh) archives `/etc` into `/var/backups/homelab`, deletes archives older than 7 days, and creates root-only files (`umask 077`). It runs from root's crontab at 20:30 UTC: see [config/cron/homelab-backup.cron](config/cron/homelab-backup.cron).

```bash
sudo cp scripts/homelab-backup.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/homelab-backup.sh
sudo crontab -e    # add the line from config/cron/homelab-backup.cron
```

### Health check
[scripts/status.sh](scripts/status.sh) prints the date, disk usage, and whether Nginx is running.

## How to verify

| Check | Command | Expected result |
|---|---|---|
| Password login refused | `ssh -o PubkeyAuthentication=no user@<server-ip>` | `Permission denied (publickey)` |
| Firewall on | `sudo ufw status verbose` | `Status: active`, `deny (incoming)` |
| Backup ran | `sudo tail -n 5 /var/log/homelab-backup.log` | `backup finished: ...` |
| Survives a reboot | `systemctl is-active nginx` after rebooting | `active` |

## What I learned
- Verify every change. A crontab edit that didn't save and an extra character in a Git remote address were both caught only because I checked afterwards.
- Cron runs on the server's clock. My server uses UTC, so 02:00 in my time zone (UTC+5:30) is 20:30 UTC.
- `set -euo pipefail` and ShellCheck catch real bugs, including a missing `$` that would have stopped old backups from ever being deleted.

## Next steps
- Copy backups off the server to Azure Blob Storage
- Rebuild this setup automatically with Ansible

## Tools
Ubuntu Server, OpenSSH, ufw, Nginx, Bash, cron, ShellCheck, Git
