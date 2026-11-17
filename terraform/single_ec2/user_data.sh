#!/bin/bash
set -euxo pipefail
apt-get update -y
apt-get install -y docker.io docker-compose-v2
systemctl enable --now docker
# Public images built for the preceding Docker assignment.
docker pull krishna04chandak/tutedude-flask-backend:1.0
docker pull krishna04chandak/tutedude-node-frontend:1.0
docker run -d --restart unless-stopped --name flask -p 5000:5000 krishna04chandak/tutedude-flask-backend:1.0
docker run -d --restart unless-stopped --name express -p 3000:3000 -e PORT=3000 -e API_URL=http://127.0.0.1:5000 krishna04chandak/tutedude-node-frontend:1.0
