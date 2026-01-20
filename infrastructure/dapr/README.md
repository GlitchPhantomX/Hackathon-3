# LearnFlow Dapr Setup

This document describes the Dapr (Distributed Application Runtime) setup for the LearnFlow application, including installation, configuration, and usage instructions.

## 🚀 Quick Start

### Install Dapr
```bash
# Install Dapr CLI and initialize on Kubernetes
./install-dapr.sh
```

### Apply Dapr Components
```bash
# Apply all Dapr component configurations
kubectl apply -f components/
```

### Verify Installation
```bash
# Run verification script
./verify-dapr.sh
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Services      │    │     Dapr Sidecar │    │   Components    │
│ (Applications)  │◄──►│   (Runtime)      │◄──►│ (PubSub, State, │
│                 │    │                  │    │  Secrets)       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              │
                       ┌───────────────┐
                       │  Dapr Control │
                       │   Plane       │
                       │ (Operator,    │
                       │  Injector,    │
                       │  Placement)    │
                       └───────────────┘
```

Dapr provides building blocks for microservices, including service invocation, state management, pub/sub messaging, and secret management.

## 📚 Components

LearnFlow uses 3 Dapr components:

### 1. Kafka Pub/Sub (pubsub-kafka)
- **Purpose**: Event-driven messaging between services
- **Configuration**: Connects to Kafka cluster
- **Topics**: All 9 LearnFlow topics
- **Usage**: Async communication between services

### 2. PostgreSQL State Store (statestore-postgres)
- **Purpose**: State persistence for services
- **Configuration**: Connects to PostgreSQL database
- **Usage**: Store and retrieve service state

### 3. Kubernetes Secret Store (secretstore)
- **Purpose**: Secure access to secrets
- **Configuration**: Uses Kubernetes secrets
- **Usage**: Access to configuration and credentials

## 🔧 Configuration

### Dapr Annotations
To enable Dapr on your services, add these annotations to your pods:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: learnflow-service
spec:
  template:
    metadata:
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "learnflow-service"
        dapr.io/app-port: "8080"
        dapr.io/config: "dapr-config"
    spec:
      containers:
      - name: learnflow-service
        image: learnflow/service:latest
```

### Component Usage in Services
Services can interact with Dapr components using the Dapr API:

**Publish to Kafka:**
```bash
curl -X POST http://localhost:3500/v1.0/publish/pubsub-kafka/learning.query \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello from LearnFlow"}'
```

**Save State to PostgreSQL:**
```bash
curl -X POST http://localhost:3500/v1.0/state/statestore-postgres \
  -H "Content-Type: application/json" \
  -d '[{"key": "user123", "value": {"name": "John", "progress": 85}}]'
```

## 🧪 Testing

### Check Dapr Status
```bash
# Check Dapr control plane status
dapr status -k
```

### List Dapr Components
```bash
# View all Dapr components
kubectl get components -A
```

### Test Component Connectivity
```bash
# Describe a specific component
kubectl describe component pubsub-kafka -n default
kubectl describe component statestore-postgres -n default
kubectl describe component secretstore -n default
```

## 🛠️ Troubleshooting

### Common Issues

1. **Dapr Sidecar Not Injecting**
   - Verify Dapr is initialized in the cluster
   - Check pod annotations are correct
   - Ensure Dapr system pods are running

2. **Component Connection Issues**
   - Verify backend services (Kafka, PostgreSQL) are accessible
   - Check component configuration files for correct connection strings
   - Review Dapr logs: `kubectl logs -n dapr-system <dapr-pod>`

3. **Performance Issues**
   - Monitor Dapr sidecar resource usage
   - Check backend service performance
   - Review Dapr configuration for optimization

### Useful Commands

```bash
# Check Dapr system pods
kubectl get pods -n dapr-system

# View Dapr logs
kubectl logs -n dapr-system -l app=dapr-operator
kubectl logs -n dapr-system -l app=dapr-sidecar-injector

# Check Dapr sidecar versions
dapr status -k

# Get Dapr sidecar metrics
kubectl port-forward -n dapr-system svc/dapr-metrics 9090:9090

# List all Dapr-enabled apps
dapr list -k
```

## 📋 Maintenance

### Monitoring
Monitor Dapr components and control plane for optimal performance:
- Dapr sidecar resource usage
- Component connectivity and health
- Message processing rates for pub/sub
- State store performance

### Scaling Considerations
- Adjust Dapr control plane resources based on workload
- Configure component-specific scaling parameters
- Monitor sidecar performance impact on applications