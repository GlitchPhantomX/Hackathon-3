#!/bin/bash

# FastAPI Dapr Agent - Deployment Script
# Builds and deploys the generated service to Kubernetes

set -euo pipefail

SERVICE_DIR="${1:-.}"
SERVICE_NAME=$(basename "$SERVICE_DIR")

echo "Deploying service: $SERVICE_NAME from directory: $SERVICE_DIR"

# Validate that required files exist
if [ ! -f "$SERVICE_DIR/main.py" ] || [ ! -f "$SERVICE_DIR/Dockerfile" ] || [ ! -f "$SERVICE_DIR/deployment.yaml" ]; then
    echo "ERROR: Required files not found in $SERVICE_DIR"
    echo "Expected: main.py, Dockerfile, deployment.yaml"
    exit 1
fi

# Build Docker image
IMAGE_NAME="$SERVICE_NAME:latest"

echo "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" "$SERVICE_DIR"

# Tag for local registry if using kind/minikube
if docker images | grep -q "kind-registry"; then
    docker tag "$IMAGE_NAME" "kind-registry:5000/$IMAGE_NAME"
    docker push "kind-registry:5000/$IMAGE_NAME"
    sed -i.bak "s|image: $IMAGE_NAME|image: kind-registry:5000/$IMAGE_NAME|g" "$SERVICE_DIR/deployment.yaml"
fi

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."
kubectl apply -f "$SERVICE_DIR/deployment.yaml"

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/"$SERVICE_NAME" --timeout=300s

# Check if Dapr sidecar is injected
echo "Checking Dapr sidecar injection..."
POD_NAME=$(kubectl get pods -l app="$SERVICE_NAME" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$POD_NAME" ]; then
    # Check if dapr sidecar container exists
    if kubectl get pod "$POD_NAME" -o jsonpath='{.spec.containers[*].name}' | grep -q daprd; then
        echo "✓ Dapr sidecar is injected and running"
    else
        echo "! Warning: Dapr sidecar may not be injected"
    fi
else
    echo "! Could not find pod to check Dapr sidecar"
fi

# Expose service if needed
echo "Exposing service..."
kubectl expose deployment "$SERVICE_NAME" --type=NodePort --port=80 --target-port=8000 --name="$SERVICE_NAME"-external --dry-run=client -o yaml | kubectl apply -f -

# Show deployment status
echo "Deployment status:"
kubectl get deployments,pods,services -l app="$SERVICE_NAME"

echo "Deployment completed!"
echo "Service URL: http://$(kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')$(kubectl get service "$SERVICE_NAME"-external -o jsonpath=':{.spec.ports[0].nodePort}')"