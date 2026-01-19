#!/bin/bash

# Build the Docker image
echo "Building Docker image..."
docker build -t learnflow-frontend:latest .

# Tag the image for registry (if needed)
# docker tag learnflow-frontend:latest your-registry/learnflow-frontend:latest

# Push the image to registry (if needed)
# docker push your-registry/learnflow-frontend:latest

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-hpa-configmap.yaml

echo "Deployment completed!"