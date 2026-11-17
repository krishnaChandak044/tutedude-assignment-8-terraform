#!/bin/bash
set -euxo pipefail
apt-get update -y && apt-get install -y docker.io
systemctl enable --now docker
docker pull krishna04chandak/tutedude-node-frontend:1.0
docker run -d --restart unless-stopped --name express -p 3000:3000 -e PORT=3000 -e API_URL=http://${backend_ip}:5000 krishna04chandak/tutedude-node-frontend:1.0
