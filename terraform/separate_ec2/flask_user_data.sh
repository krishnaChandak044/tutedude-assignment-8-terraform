#!/bin/bash
set -euxo pipefail
apt-get update -y && apt-get install -y docker.io
systemctl enable --now docker
docker pull krishna04chandak/tutedude-flask-backend:1.0
docker run -d --restart unless-stopped --name flask -p 5000:5000 krishna04chandak/tutedude-flask-backend:1.0
