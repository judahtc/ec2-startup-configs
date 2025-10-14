#!/bin/bash
set -e
echo "📦 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo " Installing Python and pip..."
sudo apt install -y python3 python3-pip

echo " Installing AWS CLI..."
# Download the AWS CLI v2 installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Install unzip if not already installed
sudo apt update && sudo apt install -y unzip

# Unzip the installer
unzip awscliv2.zip

# Run the installer
sudo ./aws/install

# Verify installation
aws --version
