#!/bin/bash

# Kafka K8s Setup - Deploy Script
# Deploys Apache Kafka on Kubernetes using Helm

set -euo pipefail

echo "Starting Kafka deployment on Kubernetes..."

# Add Bitnami Helm repository
echo "Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Check if Kafka release already exists
if helm status kafka 2>/dev/null; then
    echo "Kafka release already exists, upgrading..."
    helm upgrade kafka bitnami/kafka \
        --set replicaCount=1 \
        --set zookeeper.enabled=true \
        --set zookeeper.replicaCount=1 \
        --wait \
        --timeout=10m
else
    echo "Installing Kafka with Helm..."
    helm install kafka bitnami/kafka \
        --set replicaCount=1 \
        --set zookeeper.enabled=true \
        --set zookeeper.replicaCount=1 \
        --wait \
        --timeout=10m
fi

echo "Kafka deployment initiated successfully."
echo "Deployment complete. Use verify.py to check status."