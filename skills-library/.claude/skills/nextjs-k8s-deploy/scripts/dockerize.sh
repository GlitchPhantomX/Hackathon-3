#!/bin/bash

# NextJS K8s Deploy - Dockerize Script
# Creates Dockerfile and builds the Next.js application container

set -euo pipefail

APP_DIR="${1:-.}"
IMAGE_NAME="${2:-learnflow-frontend:latest}"

echo "Dockerizing Next.js application in: $APP_DIR"

if [ ! -d "$APP_DIR" ]; then
    echo "ERROR: Directory $APP_DIR does not exist"
    exit 1
fi

cd "$APP_DIR"

# Copy the Dockerfile template to the app directory
cp scripts/templates/Dockerfile.template Dockerfile

# Update package.json to enable standalone output
if [ -f "package.json" ]; then
    # Create a temporary package.json with standalone output enabled
    jq '. += {"next": {"output": "standalone"}}' package.json > package.json.tmp && mv package.json.tmp package.json
    echo "Updated package.json for standalone output"
else
    echo "WARNING: package.json not found in $APP_DIR"
fi

# Build the Docker image
echo "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

# Verify the image was built
if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$IMAGE_NAME"; then
    echo "✓ Docker image built successfully: $IMAGE_NAME"
    echo "Image size:"
    docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "$IMAGE_NAME"
else
    echo "✗ Failed to build Docker image: $IMAGE_NAME"
    exit 1
fi

# Show image details
echo ""
echo "Docker image details:"
docker inspect --format='Created: {{.Created}} | Size: {{.Size}}' "$IMAGE_NAME"