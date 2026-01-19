#!/bin/bash

# Postgres K8s Setup - Deploy Script
# Deploys PostgreSQL on Kubernetes using Helm

set -euo pipefail

echo "Starting PostgreSQL deployment on Kubernetes..."

# Create namespace for PostgreSQL if it doesn't exist
NAMESPACE="postgres-db"
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
else
    echo "Namespace $NAMESPACE already exists"
fi

# Add PostgreSQL Helm repository
echo "Adding PostgreSQL Helm repository..."
helm repo add postgresql https://charts.bitnami.com/bitnami
helm repo update

# Check if PostgreSQL release already exists
if helm status postgresql -n "$NAMESPACE" 2>/dev/null; then
    echo "PostgreSQL release already exists, upgrading..."
    helm upgrade postgresql bitnami/postgresql \
        --namespace "$NAMESPACE" \
        --set auth.postgresPassword=secretpassword \
        --set auth.database=learnflow \
        --set primary.persistence.enabled=true \
        --set primary.persistence.size=10Gi \
        --set primary.resources.requests.memory=256Mi \
        --set primary.resources.requests.cpu=250m \
        --set primary.resources.limits.memory=512Mi \
        --set primary.resources.limits.cpu=500m \
        --wait \
        --timeout=10m
else
    echo "Installing PostgreSQL with Helm..."
    helm install postgresql bitnami/postgresql \
        --namespace "$NAMESPACE" \
        --set auth.postgresPassword=secretpassword \
        --set auth.database=learnflow \
        --set primary.persistence.enabled=true \
        --set primary.persistence.size=10Gi \
        --set primary.resources.requests.memory=256Mi \
        --set primary.resources.requests.cpu=250m \
        --set primary.resources.limits.memory=512Mi \
        --set primary.resources.limits.cpu=500m \
        --wait \
        --timeout=10m
fi

echo "PostgreSQL deployment initiated successfully."
echo "Deployment complete. Use verify.py to check connection."