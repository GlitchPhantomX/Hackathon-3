#!/bin/bash

# NextJS K8s Deploy - Deploy Script
# Deploys the Next.js application to Kubernetes

set -euo pipefail

APP_DIR="${1:-.}"

echo "Deploying Next.js application to Kubernetes"

if [ ! -d "$APP_DIR" ]; then
    echo "ERROR: Directory $APP_DIR does not exist"
    exit 1
fi

cd "$APP_DIR"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if Docker image exists locally
IMAGE_NAME="learnflow-frontend:latest"
if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "$IMAGE_NAME"; then
    echo "ERROR: Docker image $IMAGE_NAME not found. Run dockerize.sh first."
    exit 1
fi

# Copy the deployment template
DEPLOYMENT_FILE="deployment.yaml"
cp scripts/templates/deployment.yaml.template "$DEPLOYMENT_FILE"

# If using Kind or Minikube, load the image into the cluster
if kubectl cluster-info 2>/dev/null | grep -q "kind\|minikube"; then
    echo "Detected Kind/Minikube cluster, loading image..."
    if command -v kind &> /dev/null; then
        kind load docker-image "$IMAGE_NAME" --name kind 2>/dev/null || echo "Kind cluster not found, assuming Minikube"
    elif command -v minikube &> /dev/null; then
        minikube image load "$IMAGE_NAME" 2>/dev/null || echo "Loading image to Minikube"
    fi
fi

# Apply the deployment
echo "Applying Kubernetes deployment..."
kubectl apply -f "$DEPLOYMENT_FILE"

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/learnflow-frontend --timeout=300s

# Expose the service if it doesn't exist
if ! kubectl get service learnflow-frontend-service &> /dev/null; then
    echo "Creating service..."
    kubectl expose deployment learnflow-frontend --type=LoadBalancer --port=80 --target-port=3000 --name=learnflow-frontend-service --dry-run=client -o yaml | kubectl apply -f -
fi

# Wait for service to be available
echo "Waiting for service to be available..."
kubectl wait --for=condition=ready pod -l app=learnflow-frontend --timeout=120s

# Show deployment status
echo "Deployment status:"
kubectl get deployments,pods,services -l app=learnflow-frontend

# Get the service URL
SERVICE_URL=""
if kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}' &> /dev/null; then
    EXTERNAL_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
    NODE_PORT=$(kubectl get service learnflow-frontend-service -o jsonpath='{.spec.ports[0].nodePort}')
    SERVICE_URL="http://$EXTERNAL_IP:$NODE_PORT"
elif kubectl get service learnflow-frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' &> /dev/null; then
    LB_IP=$(kubectl get service learnflow-frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    SERVICE_URL="http://$LB_IP"
else
    SERVICE_URL="Service IP not available (may be pending)"
fi

echo ""
echo "✓ Next.js application deployed successfully!"
echo "Application URL: $SERVICE_URL"
echo ""
echo "To access the application:"
echo "1. Wait for external IP to be assigned (may take a few minutes)"
echo "2. Visit the URL above or use 'kubectl port-forward' for local testing:"
echo "   kubectl port-forward svc/learnflow-frontend-service 3000:80"