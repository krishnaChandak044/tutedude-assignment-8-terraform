#!/bin/bash
apt-get update -y && apt-get install -y nodejs npm
# Install Express source/dependencies; configure API_URL to Flask's private IP and run systemd service.
