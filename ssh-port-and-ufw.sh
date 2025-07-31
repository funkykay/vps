#!/usr/bin/env bash

set -e

SSH_PORT="${SSH_PORT:-2222}"
echo "SSH-Port wird auf ${SSH_PORT} gesetzt"

apt install -y ufw
ufw allow "${SSH_PORT}/tcp"
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

sed -i "s/^#Port 22/Port ${SSH_PORT}/" /etc/ssh/sshd_config
systemctl restart ssh
