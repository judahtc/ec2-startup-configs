#!/bin/bash
set -e

# -------- CONFIG --------
AWS_REGION="eu-west-1"
AWS_ACCOUNT_ID="165194454526"
REPO_NAME="docker-ec2-test"
TAG="latest"
# ------------------------

echo "📦 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo "🐳 Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER


echo " Versions:"
docker --version
