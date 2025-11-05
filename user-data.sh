#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -e

echo "📦 Updating system packages..."
apt update -y
apt upgrade -y

echo "🐳 Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install AWS CLI v2
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# ./aws/install



# -------- CONFIG --------
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="637423647279"
REPO_NAME="innbucks_service"
TAG="latest"
# ------------------------

echo "🔑 Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "📦 Pulling image from ECR..."
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG

# Stop old container if it exists
PORT=8083
CONTAINER_ID=$(docker ps -q --filter "publish=${PORT}")
if [ -n "$CONTAINER_ID" ]; then
    echo "🛑 Stopping old container..."
    docker stop $CONTAINER_ID
    docker rm $CONTAINER_ID
fi

echo "🚀 Starting container..."
docker run -d -p 8083:8083 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG

echo "🪄 Installing CodeDeploy agent..."
apt install -y ruby wget
cd /home/ubuntu
wget https://aws-codedeploy-$AWS_REGION.s3.$AWS_REGION.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl enable codedeploy-agent
systemctl start codedeploy-agent

echo "✅ Setup complete!"
