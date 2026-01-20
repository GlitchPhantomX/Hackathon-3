# LearnFlow Infrastructure

This directory contains all infrastructure components for the LearnFlow application, including Kafka for messaging, PostgreSQL for data persistence, and Dapr for distributed application runtime capabilities.

## 🏗️ Architecture Overview

The LearnFlow infrastructure consists of three main components:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Services      │    │     Kafka        │    │   PostgreSQL    │
│ (Backend Apps)  │◄──►│   (Messaging)    │◄──►│  (Persistence)  │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              │
                       ┌───────────────┐
                       │     Dapr      │
                       │  (Runtime)    │
                       └───────────────┘
```

### Components

#### 1. Kafka (Event Streaming)
- **Purpose**: Event streaming platform for microservices communication
- **Topics**: 9 LearnFlow-specific topics for different service communications
- **Configuration**: Optimized for development environment with appropriate retention settings
- **Documentation**: [Kafka README](kafka/README.md)

#### 2. PostgreSQL (Data Persistence)
- **Purpose**: Primary database for storing application data
- **Schema**: 9 tables supporting user management, curriculum, exercises, and progress tracking
- **Seed Data**: Initial data for development and testing
- **Documentation**: [PostgreSQL README](postgres/README.md)

#### 3. Dapr (Distributed App Runtime)
- **Purpose**: Provides building blocks for distributed applications
- **Components**:
  - Kafka pub/sub for messaging
  - PostgreSQL state store for data persistence
  - Kubernetes secret store for secure access
- **Documentation**: [Dapr README](dapr/README.md)

## 🚀 Quick Deploy

### Prerequisites
Ensure all prerequisites are met before deploying:
```bash
./check-prerequisites.sh
```

### Full Deployment
Deploy all infrastructure components at once:
```bash
./deploy-all.sh
```

### Verification
Verify all components are operational:
```bash
./verify-all.sh
```

### Component-Specific Deployments
Deploy individual components separately if needed:

**Kafka only:**
```bash
cd kafka
./create-topics.sh
cd ..
```

**PostgreSQL only:**
```bash
# PostgreSQL is deployed as part of the main deployment
```

**Dapr only:**
```bash
cd dapr
./install-dapr.sh
kubectl apply -f components/
cd ..
```

## 🔌 Connection Details

### Kafka
- **Bootstrap Server**: `kafka.kafka.svc.cluster.local:9092`
- **Topics**: See [Kafka README](kafka/README.md#topics-overview) for complete list

### PostgreSQL
- **Host**: `postgresql.postgres.svc.cluster.local:5432`
- **Database**: `learnflow_db`
- **Username**: `learnflow`
- **Password**: `learnflow_dev_pass`

### Dapr
- **Sidecar Injection**: Annotate pods with `dapr.io/enabled: "true"`
- **App Port**: Services should expose their API port
- **App ID**: Use consistent app IDs across environments

## 🛠️ Troubleshooting

### Common Issues

1. **Deployment Failures**
   - Check available resources on Kubernetes cluster
   - Verify network connectivity for pulling images
   - Ensure Helm repositories are accessible

2. **Service Connectivity**
   - Verify services are running and accessible within the cluster
   - Check DNS resolution between services
   - Confirm network policies allow required traffic

3. **Storage Issues**
   - Verify PersistentVolumes are available
   - Check storage class configuration
   - Monitor disk space utilization

### Useful Commands

```bash
# Check all infrastructure pods
kubectl get pods -A | grep -E "(kafka|postgres|dapr)"

# Check all infrastructure services
kubectl get svc -A | grep -E "(kafka|postgres|dapr)"

# View logs for Kafka
kubectl logs -n kafka -l app.kubernetes.io/name=kafka

# View logs for PostgreSQL
kubectl logs -n postgres -l app.kubernetes.io/name=postgresql

# Check Dapr status
dapr status -k

# Check all Dapr components
kubectl get components -A
```

## 📋 Maintenance

### Regular Checks
- Monitor resource utilization
- Verify backup and recovery procedures
- Check for security updates
- Review log retention policies

### Scaling Considerations
- Increase resources based on usage patterns
- Add more Kafka partitions for high-throughput topics
- Adjust PostgreSQL connection pooling settings
- Consider Dapr component performance tuning

## 🚀 Next Steps

This completes Part 1: Infrastructure Foundation. The next phase involves:

1. **Part 2: Backend Services** - Deploying the LearnFlow backend services
2. **Part 3: Frontend Integration** - Connecting the frontend to the backend
3. **Part 4: CI/CD Pipeline** - Automating deployments and testing

Continue to the [LearnFlow Backend Services](../learnflow-app/backend/README.md) for the next phase of deployment.