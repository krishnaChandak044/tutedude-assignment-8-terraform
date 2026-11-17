#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_REGION:-ap-southeast-2}"
FLASK_REPO="${1:?usage: push-ecr-images.sh FLASK_ECR_URI EXPRESS_ECR_URI}"
EXPRESS_REPO="${2:?usage: push-ecr-images.sh FLASK_ECR_URI EXPRESS_ECR_URI}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
docker build -t "$FLASK_REPO:latest" ../../app/backend
docker push "$FLASK_REPO:latest"
docker build -t "$EXPRESS_REPO:latest" ../../app/frontend
docker push "$EXPRESS_REPO:latest"
