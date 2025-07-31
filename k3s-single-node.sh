#!/usr/bin/env bash

set -e

K3S_VERSION="${K3S_VERSION:-latest}"
KUBECONFIG_DIR="$HOME/.kube"
KUBECONFIG_FILE="$KUBECONFIG_DIR/config"

uptime_seconds=$(awk '{print int($1)}' /proc/uptime)
if [ "$uptime_seconds" -lt 300 ]; then
  echo "System frisch gebootet (<5 Min) – Warte 30 Sekunden auf stabiles Netzwerk..."
  sleep 30
fi

echo "K3s wird installiert..."
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--disable servicelb --disable metrics-server --write-kubeconfig-mode 644" \
  K3S_VERSION="$K3S_VERSION" sh -

echo "Kubeconfig für aktuellen User wird eingerichtet..."
mkdir -p "$KUBECONFIG_DIR"
sudo cp /etc/rancher/k3s/k3s.yaml "$KUBECONFIG_FILE"
sudo chown "$(id -u)":"$(id -g)" "$KUBECONFIG_FILE"

echo "Helm wird installiert..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "K3s Setup abgeschlossen. Statusübersicht:"
kubectl get nodes || echo "Warnung: kubectl konnte den Cluster noch nicht erreichen."

echo "Fertig."
