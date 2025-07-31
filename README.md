# vps setup

```bash
#!/usr/bin/env bash
set -e
apt update && apt upgrade -y
curl -sSL https://raw.githubusercontent.com/funkykay/vps/refs/heads/main/ssh-port-and-ufw.sh | bash
curl -sSL https://raw.githubusercontent.com/funkykay/vps/refs/heads/main/k3s-single-node.sh | bash
```
