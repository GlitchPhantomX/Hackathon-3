# Dapr K8s Setup Skill

This skill sets up Dapr on Kubernetes for the LearnFlow application.

## Description
Installs Dapr and configures LearnFlow-specific components including pub/sub and state management.

## Prerequisites
- Kubernetes cluster access
- Dapr CLI (will be installed if missing)
- kubectl configured

## Parameters
- namespace: Target namespace for components (default: default)

## Execution
```bash
# Install Dapr CLI and initialize
./install-dapr.sh

# Apply component configurations
kubectl apply -f components/
```

## Verification
Check Dapr status and component configuration:
```bash
dapr status -k
kubectl get components
```