#!/bin/bash
apt-get update -y && apt-get install -y python3-pip python3-venv
# Install project source, dependencies, then run Flask bound to 0.0.0.0:5000 under systemd.
