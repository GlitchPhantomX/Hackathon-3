#!/bin/bash

# Master Infrastructure Deployment Script for LearnFlow
# Deploys Kafka, PostgreSQL, and Dapr in the correct sequence

set -e  # Exit on any error

echo "🚀 Starting LearnFlow Infrastructure Deployment..."
echo ""

# Function to print section headers
print_header() {
    echo "################################################################################"
    echo "# $1"
    echo "################################################################################"
    echo ""
}

# Function to run commands with error handling
run_command() {
    echo "📍 Executing: $1"
    if eval "$1"; then
        echo "✅ Success: $1"
        echo ""
    else
        echo "❌ Failed: $1"
        exit 1
    fi
}

# Section 1: Prerequisites Check
print_header "Section 1: Prerequisites Check"

echo "🔍 Checking prerequisites..."
if [ -f "./check-prerequisites.sh" ]; then
    run_command "./check-prerequisites.sh"
else
    echo "⚠️  Prerequisites check script not found, skipping..."
fi

# Section 2: Add Helm Repositories
print_header "Section 2: Add Helm Repositories"

echo "📦 Adding Helm repositories..."
run_command "helm repo add bitnami https://charts.bitnami.com/bitnami"
run_command "helm repo update"

# Section 3: Deploy Kafka
print_header "Section 3: Deploy Kafka"

echo "📍 Creating Kafka namespace..."
run_command "kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -"

echo "📍 Deploying Kafka with custom values..."
run_command "helm install kafka bitnami/kafka --namespace kafka --values kafka/values.yaml --wait --timeout 10m"

echo "📍 Waiting for Kafka to be ready..."
run_command "kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kafka -n kafka --timeout=300s"

echo "📍 Creating Kafka topics..."
run_command "cd kafka && ./create-topics.sh"

echo "📍 Verifying Kafka deployment..."
run_command "cd kafka && ./verify-kafka.sh"
cd ..

# Section 4: Deploy PostgreSQL
print_header "Section 4: Deploy PostgreSQL"

echo "📍 Creating PostgreSQL namespace..."
run_command "kubectl create namespace postgres --dry-run=client -o yaml | kubectl apply -f -"

echo "📍 Deploying PostgreSQL with custom values..."
run_command "helm install postgresql bitnami/postgresql --namespace postgres --values postgres/values.yaml --wait --timeout 10m"

echo "📍 Waiting for PostgreSQL to be ready..."
run_command "kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql -n postgres --timeout=300s"

echo "📍 Verifying PostgreSQL deployment..."
run_command "cd postgres && ./verify-postgres.sh"
cd ..

# Section 5: Install Dapr
print_header "Section 5: Install Dapr"

echo "📍 Installing Dapr..."
run_command "cd dapr && ./install-dapr.sh"
cd ..

echo "📍 Applying Dapr components..."
run_command "kubectl apply -f dapr/components/"

# Section 6: Final Verification
print_header "Section 6: Final Infrastructure Verification"

echo "📍 Running comprehensive verification..."
if [ -f "./verify-all.sh" ]; then
    run_command "./verify-all.sh"
else
    echo "📍 Individual component verifications:"
    echo "📍 Kafka verification:"
    cd kafka && ./verify-kafka.sh && cd ..
    echo "📍 PostgreSQL verification:"
    cd postgres && ./verify-postgres.sh && cd ..
    echo "📍 Dapr verification:"
    dapr status -k
fi

echo "🎉 All LearnFlow infrastructure components deployed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "✅ Kafka deployed with all 9 topics"
echo "✅ PostgreSQL deployed with complete schema and seed data"
echo "✅ Dapr installed with pub/sub and state components"
echo "✅ All services accessible within cluster"
echo "✅ All verification scripts passed"
echo ""
echo "🚀 LearnFlow infrastructure is ready for use!"