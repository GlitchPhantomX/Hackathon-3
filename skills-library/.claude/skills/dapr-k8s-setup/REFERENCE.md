# Dapr Reference Guide

This document provides detailed information about Dapr components and configuration for LearnFlow.

## Components

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

## Configuration

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

## Troubleshooting

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