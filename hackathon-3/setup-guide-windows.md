# Hackathon III - Windows Setup Guide with WSL

## Prerequisites Installation Guide for Windows

This guide will walk you through installing all the required tools for Hackathon III on Windows using WSL (Windows Subsystem for Linux).

## 1. Install WSL2

First, ensure WSL2 is installed and configured:

```powershell
# Run in PowerShell as Administrator
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart your computer
shutdown /r /t 5

# After restart, set WSL2 as default
wsl --set-default-version 2
```

Then install a Linux distribution (Ubuntu 20.04 LTS recommended) from the Microsoft Store.

## 2. Install Docker Desktop for Windows

1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Install Docker Desktop (includes WSL 2 backend support)
3. During installation, ensure you select "Use WSL 2 based engine"
4. After installation, start Docker Desktop
5. Go to Settings > General and ensure "Use WSL 2 based engine" is checked
6. Go to Settings > Resources > WSL Integration and enable integration with your Linux distro

## 3. Install Minikube

In your WSL terminal:

```bash
# Download and install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

## 4. Install kubectl

In your WSL terminal:

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

## 5. Install Helm 3

In your WSL terminal:

```bash
# Download and install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

## 6. Start Minikube Cluster

In your WSL terminal:

```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --driver=docker

# Verify cluster is running
kubectl cluster-info
```

## 7. Verification Script

Create a verification script to check all installations:

```bash
#!/bin/bash

echo "=== Hackathon III Setup Verification ==="

echo "1. Checking Docker..."
if command -v docker &> /dev/null; then
    echo "✓ Docker version: $(docker --version)"
    echo "✓ Docker daemon status:"
    docker info 2>/dev/null | head -5
else
    echo "✗ Docker not found"
fi

echo ""
echo "2. Checking kubectl..."
if command -v kubectl &> /dev/null; then
    echo "✓ kubectl version: $(kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | head -1)"
else
    echo "✗ kubectl not found"
fi

echo ""
echo "3. Checking Minikube..."
if command -v minikube &> /dev/null; then
    echo "✓ Minikube version: $(minikube version)"
    if minikube status &> /dev/null; then
        echo "✓ Minikube cluster status:"
        minikube status
    else
        echo "⚠ Minikube cluster not running"
    fi
else
    echo "✗ Minikube not found"
fi

echo ""
echo "4. Checking Helm..."
if command -v helm &> /dev/null; then
    echo "✓ Helm version: $(helm version --short)"
else
    echo "✗ Helm not found"
fi

echo ""
echo "5. Checking Kubernetes connectivity..."
if kubectl cluster-info &> /dev/null; then
    echo "✓ Connected to Kubernetes cluster"
    echo "✓ Cluster Info:"
    kubectl cluster-info | head -3
else
    echo "✗ Cannot connect to Kubernetes cluster"
fi

echo ""
echo "=== Verification Complete ==="
```

## 8. Save the verification script to hackathon-3/verify-setup.sh

After creating the script, make it executable:

```bash
chmod +x verify-setup.sh
./verify-setup.sh
```

## Troubleshooting Tips

1. **Docker Issues**: Ensure Windows Hyper-V and Containers features are enabled
2. **Minikube Issues**: If minikube start fails, try `minikube delete` and restart
3. **WSL Integration**: Make sure Docker Desktop WSL integration is enabled for your distro
4. **Resource Issues**: Ensure your system has at least 16GB RAM for the specified minikube settings

Once all tools are installed and verified, you'll be ready to proceed with the Hackathon III challenges.