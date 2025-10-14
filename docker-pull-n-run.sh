AWS_REGION="eu-west-1"
AWS_ACCOUNT_ID="419772637660"
REPO_NAME="atapi"
TAG="latest"

echo "🔑 Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | \
sudo docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo " Pulling image from ECR..."
sudo docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG

echo "🎉 Done! Image pulled successfully from ECR."

PORT=8000

# Find the container ID using the port
CONTAINER_ID=$(sudo docker ps -q --filter "publish=${PORT}")

# If a container is found, stop it
if [ -n "$CONTAINER_ID" ]; then
    echo "Stopping container $CONTAINER_ID using port $PORT..."
    sudo docker stop $CONTAINER_ID
    sudo docker rm $CONTAINER_ID
fi

sudo docker run -d -p 8000:8000 419772637660.dkr.ecr.eu-west-1.amazonaws.com/atapi
