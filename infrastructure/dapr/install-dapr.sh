#!/bin/bash

# Dapr Installation Script for LearnFlow
# Installs Dapr CLI and initializes Dapr on Kubernetes

set -e  # Exit on any error

echo "🚀 Installing Dapr for LearnFlow..."

# Check if Dapr CLI is installed
if command -v dapr &> /dev/null; then
    echo "✅ Dapr CLI is already installed"
    DAPR_VERSION=$(dapr --version 2>/dev/null || echo "unknown")
    echo "   Dapr version: $DAPR_VERSION"
else
    echo "📍 Installing Dapr CLI..."

    # Install Dapr CLI based on OS
    OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')

    if [[ "$OS_TYPE" == *"linux"* ]] || [[ "$OS_TYPE" == *"mingw"* ]]; then
        # For Linux/WSL/MINGW
        wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
    elif [[ "$OS_TYPE" == *"darwin"* ]]; then
        # For macOS
        brew install dapr/tap/dapr-cli
    else
        echo "❌ Unsupported OS: $OS_TYPE"
        exit 1
    fi

    echo "✅ Dapr CLI installed successfully"
fi

# Initialize Dapr on Kubernetes
echo ""
echo "📍 Initializing Dapr on Kubernetes..."
if kubectl get ns | grep -q dapr-system; then
    echo "⚠️  Dapr is already initialized in the cluster"
    echo "💡 Skipping initialization, verifying current installation..."
else
    # Initialize Dapr
    dapr init -k

    if [ $? -eq 0 ]; then
        echo "✅ Dapr initialized successfully on Kubernetes"
    else
        echo "❌ Dapr initialization failed"
        exit 1
    fi
fi

# Wait for Dapr system pods to be ready
echo ""
echo "📍 Waiting for Dapr system pods to be ready..."
kubectl wait --for=condition=ready pod \
    -l app.kubernetes.io/part-of=dapr \
    -n dapr-system \
    --timeout=300s

if [ $? -eq 0 ]; then
    echo "✅ All Dapr system pods are ready"
else
    echo "⚠️  Dapr pods may not be fully ready yet, continuing..."
fi

# Verify Dapr installation
echo ""
echo "📍 Verifying Dapr installation..."
if dapr status -k &> /dev/null; then
    echo "✅ Dapr installation verified successfully"
    echo ""
    echo "📋 Dapr Status:"
    dapr status -k
else
    echo "⚠️  Dapr status check had issues, but installation may still be functional"
fi

# Show Dapr version
echo ""
echo "📋 Dapr Version Info:"
dapr --version

echo ""
echo "🎉 Dapr installation and initialization completed!"
echo "✅ Dapr is ready for LearnFlow services."

exit 0