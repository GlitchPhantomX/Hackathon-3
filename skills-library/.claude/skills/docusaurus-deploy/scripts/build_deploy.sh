#!/bin/bash

# Docusaurus Deploy - Build and Deploy Script
# Builds the Docusaurus site and deploys to Kubernetes

set -euo pipefail

SITE_DIR="${1:-.}"
IMAGE_NAME="${2:-docusaurus-docs:latest}"

echo "Building and deploying Docusaurus site from: $SITE_DIR"

if [ ! -d "$SITE_DIR" ]; then
    echo "ERROR: Directory $SITE_DIR does not exist"
    exit 1
fi

cd "$SITE_DIR"

# Check if docusaurus is installed
if ! command -v npx &> /dev/null || ! npx docusaurus --version &> /dev/null; then
    echo "Installing Docusaurus CLI..."
    npm install @docusaurus/core @docusaurus/preset-classic
fi

# Build the Docusaurus site
echo "Building Docusaurus site..."
npm run build

# Create Dockerfile for the built site
cat > Dockerfile << 'EOF'
FROM nginx:alpine

# Copy built site to nginx html directory
COPY build/ /usr/share/nginx/html/

# Copy custom nginx configuration if it exists
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

# Create a basic nginx configuration for proper routing
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    server {
        listen 80;
        server_name localhost;

        # Serve static files with proper caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Handle client-side routing for SPA
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF

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

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed or not in PATH"
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
kubectl rollout status deployment/docusaurus-docs --timeout=300s

# Show deployment status
echo "Deployment status:"
kubectl get deployments,pods,services,ingress -l app=docusaurus-docs

# Get the service URL
SERVICE_URL=""
if kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}' &> /dev/null; then
    EXTERNAL_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
    NODE_PORT=$(kubectl get service docusaurus-docs-service -o jsonpath='{.spec.ports[0].nodePort}')
    SERVICE_URL="http://$EXTERNAL_IP:$NODE_PORT"
elif kubectl get service docusaurus-docs-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' &> /dev/null; then
    LB_IP=$(kubectl get service docusaurus-docs-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    SERVICE_URL="http://$LB_IP"
else
    SERVICE_URL="Service IP not available (may be pending)"
fi

echo ""
echo "✓ Docusaurus site deployed successfully!"
echo "Site URL: $SERVICE_URL"
echo ""
echo "To access the documentation site:"
echo "1. Wait for external IP to be assigned (may take a few minutes)"
echo "2. Visit the URL above or use 'kubectl port-forward' for local testing:"
echo "   kubectl port-forward svc/docusaurus-docs-service 3000:80"
echo ""
echo "Search functionality should be working with the default Docusaurus search."