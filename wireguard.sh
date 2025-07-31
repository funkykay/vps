#!/usr/bin/env bash

set -e

# === Konfigurierbare Parameter ===
WG_INTERFACE="wg0"
WG_PORT=51820
WG_NET="10.0.0.0/24"
WG_SERVER_IP="10.0.0.1"
CLIENT_IP="10.0.0.2"
SERVER_PRIV_KEY_FILE="server_private.key"
CLIENT_PUB_KEY_PLACEHOLDER="REPLACE_WITH_CLIENT_PUBLIC_KEY"

# === Installiere WireGuard ===
echo "[+] Installing WireGuard..."
apt update && apt install -y wireguard

# === Key generieren ===
echo "[+] Generating server key..."
umask 077
wg genkey | tee ${SERVER_PRIV_KEY_FILE} | wg pubkey > server_public.key

SERVER_PRIV_KEY=$(cat ${SERVER_PRIV_KEY_FILE})

# === Konfiguration schreiben ===
echo "[+] Writing WireGuard config..."

cat <<EOF > /etc/wireguard/${WG_INTERFACE}.conf
[Interface]
Address = ${WG_SERVER_IP}/24
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIV_KEY}

# Client peer
[Peer]
PublicKey = ${CLIENT_PUB_KEY_PLACEHOLDER}
AllowedIPs = ${CLIENT_IP}/32
EOF

# === IP-Forwarding aktivieren ===
echo "[+] Enabling IP forwarding..."
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard.conf
sysctl --system

# === Firewall konfigurieren ===
echo "[+] Configuring firewall..."
iptables -A FORWARD -i ${WG_INTERFACE} -j ACCEPT
iptables -A FORWARD -o ${WG_INTERFACE} -j ACCEPT
iptables -t nat -A POSTROUTING -s ${WG_NET} -o eth0 -j MASQUERADE

# === WireGuard starten ===
echo "[+] Starting WireGuard..."
systemctl enable wg-quick@${WG_INTERFACE}
systemctl start wg-quick@${WG_INTERFACE}

echo "[✔] WireGuard setup complete."
echo
echo "==> Server public key:"
cat server_public.key
echo
echo "⚠️  Jetzt auf dem Client den Public Key des Clients generieren und in die Config eintragen."
