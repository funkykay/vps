#!/usr/bin/env bash

set -e

K3S_VERSION="${K3S_VERSION:-latest}"
KUBECONFIG_DIR="$HOME/.kube"
KUBECONFIG_FILE="$KUBECONFIG_DIR/config"

echo "System wird aktualisiert..."
sudo apt update && sudo apt upgrade -y

echo "K3s (version: $K3S_VERSION) wird installiert..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable servicelb --disable metrics-server" sh -

echo "Kubeconfig für aktuellen User wird eingerichtet..."
mkdir -p "$KUBECONFIG_DIR"
sudo cp /etc/rancher/k3s/k3s.yaml "$KUBECONFIG_FILE"
sudo chown $(id -u):$(id -g) "$KUBECONFIG_FILE"

echo "Helm wird installiert..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "K3s Setup abgeschlossen. Statusübersicht:"
kubectl get nodes

echo "Fertig! Für produktiven Betrieb: Monitoring, Backups und Hardening nicht vergessen."
