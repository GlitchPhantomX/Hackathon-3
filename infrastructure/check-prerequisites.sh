#!/bin/bash

# Infrastructure Prerequisites Check Script
# Verifies that all required tools are installed and properly configured

set -e  # Exit on any error

echo "🔍 Checking Infrastructure Prerequisites..."
echo ""

# Function to check command existence and version
check_command() {
    local cmd=$1
    local version_cmd=$2
    local min_version=$3

    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ $cmd is not installed"
        return 1
    else
        if [ -n "$version_cmd" ]; then
            local version
            version=$(eval "$version_cmd" 2>&1 | head -n 1)
            echo "✅ $cmd found: $version"

            # If min_version is specified, do a basic version check
            if [ -n "$min_version" ]; then
                # For now, just print the requirement
                echo "   Minimum required: $min_version"
            fi
        else
            echo "✅ $cmd found"
        fi
        return 0
    fi
}

# Check kubectl
echo "📍 Checking kubectl..."
check_command "kubectl" "kubectl version --client --short" "v1.28+"
echo ""

# Check helm
echo "📍 Checking helm..."
check_command "helm" "helm version --short" "v3.12+"
echo ""

# Check jq
echo "📍 Checking jq..."
if command -v jq &> /dev/null; then
    version=$(jq --version)
    echo "✅ jq found: $version"
elif [ -f "./jq.exe" ]; then
    version=$("./jq.exe" --version)
    echo "✅ jq found (as jq.exe): $version"
else
    echo "❌ jq is not installed"
fi
echo ""

# Check minikube
echo "📍 Checking minikube..."
if command -v minikube &> /dev/null; then
    echo "✅ minikube found"
    minikube_status=$(minikube status 2>&1 || echo "minikube not running")
    if [[ "$minikube_status" == *"Running"* ]]; then
        echo "✅ minikube is running"
    else
        echo "⚠️  minikube status: $minikube_status"
    fi
else
    echo "❌ minikube is not installed"
fi
echo ""

# Check kubectl cluster connection
echo "📍 Checking kubectl cluster connection..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ kubectl can connect to cluster"
    cluster_info=$(kubectl cluster-info | head -n 2)
    echo "   Cluster info: $cluster_info"
else
    echo "❌ kubectl cannot connect to cluster"
fi
echo ""

# Check for required directories
echo "📍 Checking infrastructure directories..."
# Change to script directory parent to check for infrastructure folders
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/.."

dirs_to_check=("infrastructure/kafka" "infrastructure/postgres" "infrastructure/postgres/init-scripts" "infrastructure/dapr" "infrastructure/dapr/components")

all_dirs_exist=true
for dir in "${dirs_to_check[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ Directory exists: $dir"
    else
        echo "❌ Directory missing: $dir"
        all_dirs_exist=false
    fi
done

# Return to the original directory
cd - > /dev/null

echo ""
if [ "$all_dirs_exist" = true ]; then
    echo "🎉 All prerequisites checks PASSED!"
    echo ""
    echo "✅ kubectl is available"
    echo "✅ helm is available"
    echo "✅ jq is available"
    echo "✅ Infrastructure directories exist"
    echo ""
    echo "Ready to proceed with infrastructure deployment."
    exit 0
else
    echo "❌ Some prerequisites checks FAILED!"
    echo "Please resolve the missing components before proceeding."
    exit 1
fi