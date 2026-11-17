#!/bin/bash
set -eux
apt-get update -y
apt-get install -y python3-pip python3-venv nodejs npm git
mkdir -p /opt/tutedude
# Copy/clone Flask and Express project sources here, then install their requirements.
# This bootstrap creates managed systemd units once the application directories exist.
