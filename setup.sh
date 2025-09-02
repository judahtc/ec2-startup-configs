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

echo " Installing Python and pip..."
sudo apt install -y python3 python3-pip

echo " Installing AWS CLI..."
sudo apt install -y awscli

echo " Versions:"
docker --version
python3 --version
pip3 --version
aws --version

echo "🔑 Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo " Pulling image from ECR..."
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG

echo "🎉 Done! Image pulled successfully from ECR."
