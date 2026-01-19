#!/bin/bash

echo "=== Hackathon III Setup Verification ==="

echo "1. Checking Docker..."
if command -v docker &> /dev/null; then
    echo "✓ Docker version: $(docker --version)"
    if docker info &> /dev/null; then
        echo "✓ Docker daemon is running"
        echo "✓ Docker info (first 3 lines):"
        docker info 2>/dev/null | head -3
    else
        echo "✗ Docker daemon is not running"
    fi
else
    echo "✗ Docker not found"
fi

echo ""
echo "2. Checking kubectl..."
if command -v kubectl &> /dev/null; then
    kubectl_version=$(kubectl version --client --output=json 2>/dev/null | grep gitVersion | head -1 | cut -d'"' -f4)
    if [ ! -z "$kubectl_version" ]; then
        echo "✓ kubectl version: $kubectl_version"
    else
        echo "✓ kubectl found but cannot retrieve version"
    fi
else
    echo "✗ kubectl not found"
fi

echo ""
echo "3. Checking Minikube..."
if command -v minikube &> /dev/null; then
    echo "✓ Minikube version: $(minikube version 2>/dev/null || echo "Not available")"
    if minikube status &> /dev/null; then
        echo "✓ Minikube cluster is running"
        echo "✓ Minikube status:"
        minikube status 2>/dev/null
    else
        echo "✗ Minikube cluster is not running"
    fi
else
    echo "✗ Minikube not found"
fi

echo ""
echo "4. Checking Helm..."
if command -v helm &> /dev/null; then
    echo "✓ Helm version: $(helm version --short 2>/dev/null || echo "Not available")"
else
    echo "✗ Helm not found"
fi

echo ""
echo "5. Checking Kubernetes connectivity..."
if kubectl cluster-info &> /dev/null; then
    echo "✓ Successfully connected to Kubernetes cluster"
    echo "✓ Cluster Info (first 3 lines):"
    kubectl cluster-info 2>/dev/null | head -3
else
    echo "✗ Cannot connect to Kubernetes cluster"
fi

echo ""
echo "=== Verification Complete ==="