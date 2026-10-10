#!/usr/bin/env bash
 set -euo pipefail

name="sky"
echo "Hey $name"
today=$(date +%F)
echo "you visited this site on $today"
df -h /
if systemctl is-active --quiet nginx;then echo "nginx is running";else echo "nginx is down";fi


