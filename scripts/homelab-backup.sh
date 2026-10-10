#!/bin/bash
set -euo pipefail
umask 077
DEST="/var/backups/homelab"
mkdir -p "$DEST"
chmod 700 "$DEST"
today=$(date +%F)
tar -czf "$DEST/etc-$today.tar.gz" /etc
find "$DEST" -name 'etc-*.tar.gz' -mtime +7 -delete
echo "backup finished: $DEST/etc-$today.tar.gz"
