#!/bin/bash
set -e
exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "📦 Updating system packages..."
# Wait for any cloud-init or apt locks to clear
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "🔒 Waiting for other apt processes to finish..."
  sleep 5
done

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get upgrade -yq

echo "🐍 Installing Python and AWS CLI..."
sudo apt-get install -y python3 python3-pip unzip curl ruby wget docker.io

# Install AWS CLI v2 safely
echo "⬇️ Installing AWS CLI v2..."
cd /tmp
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install || true
rm -rf aws awscliv2.zip

# -------- CONFIG --------
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="637423647279"
REPO_NAME="innbucks_service"
TAG="latest"
PORT=8083
# ------------------------

echo "🔑 Logging in to Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" | sudo docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "📦 Pulling image from ECR..."
sudo docker pull "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG"

# Stop old container if it exists
CONTAINER_ID=$(sudo docker ps -q --filter "publish=${PORT}")
if [ -n "$CONTAINER_ID" ]; then
    echo "🛑 Stopping old container..."
    sudo docker stop "$CONTAINER_ID"
    sudo docker rm "$CONTAINER_ID"
fi

echo "🚀 Starting container..."
sudo docker run -d -p ${PORT}:${PORT} "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG"

echo "🪄 Installing CodeDeploy agent..."
cd /home/ubuntu
wget -q "https://aws-codedeploy-$AWS_REGION.s3.$AWS_REGION.amazonaws.com/latest/install"
chmod +x ./install
sudo ./install auto
sudo systemctl enable codedeploy-agent
sudo systemctl start codedeploy-agent

echo "✅ Setup complete!"
