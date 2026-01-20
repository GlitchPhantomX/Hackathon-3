# LearnFlow Backend Services Quickstart Guide

## Prerequisites

Before setting up the LearnFlow backend services, ensure you have the following installed:

- **Docker Desktop** (v20.10 or higher)
- **Kubernetes** (enabled in Docker Desktop or Minikube)
- **kubectl** (v1.20 or higher)
- **Helm** (v3.0 or higher)
- **Python** (v3.11 or higher)
- **OpenAI API Key** (for AI services)

## Local Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/learnflow-app.git
cd learnflow-app
```

### 2. Set Up Kubernetes Environment

If using Minikube:
```bash
minikube start --cpus=4 --memory=8192 --driver=docker
minikube addons enable ingress
```

If using Docker Desktop:
- Enable Kubernetes in Docker Desktop settings

### 3. Install Dapr

```bash
# Install Dapr CLI
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Initialize Dapr in your Kubernetes cluster
dapr init -k
```

### 4. Deploy Infrastructure Components

```bash
# Deploy Kafka using Strimzi
kubectl create namespace kafka
kubectl apply -f infrastructure/kafka-cluster.yaml -n kafka

# Deploy PostgreSQL
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgresql bitnami/postgresql -n postgres --create-namespace

# Deploy Dapr components
kubectl apply -f infrastructure/dapr/components/
```

### 5. Configure Environment Variables

Create a `.env` file in the root directory:

```bash
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4o-mini

# Database Configuration
POSTGRES_HOST=postgresql.postgres.svc.cluster.local
POSTGRES_PORT=5432
POSTGRES_DB=learnflow_db
POSTGRES_USER=learnflow
POSTGRES_PASSWORD=your_secure_password

# Kafka Configuration
KAFKA_BOOTSTRAP_SERVERS=learnflow-kafka-kafka-bootstrap.kafka.svc.cluster.local:9092

# Dapr Configuration
DAPR_HTTP_PORT=3500
DAPR_GRPC_PORT=50001
```

## Service Deployment

### 1. Build Service Images

```bash
# Set Docker to use Minikube's Docker daemon (if using Minikube)
eval $(minikube docker-env)

# Build all service images
cd backend/triage-service
docker build -t triage-service:latest .

cd ../concepts-service
docker build -t concepts-service:latest .

cd ../debug-service
docker build -t debug-service:latest .

cd ../exercise-service
docker build -t exercise-service:latest .
```

### 2. Deploy Services to Kubernetes

```bash
# Apply configurations and secrets
kubectl apply -f infrastructure/backend/backend-config.yaml
kubectl apply -f infrastructure/backend/backend-secrets.yaml

# Deploy each service
kubectl apply -f backend/triage-service/deployment.yaml
kubectl apply -f backend/concepts-service/deployment.yaml
kubectl apply -f backend/debug-service/deployment.yaml
kubectl apply -f backend/exercise-service/deployment.yaml
```

### 3. Verify Deployment

```bash
# Check if all pods are running
kubectl get pods

# Check Dapr sidecars are injected
kubectl get pods -o yaml | grep dapr

# Verify services are accessible
kubectl get services

# Check service logs
kubectl logs -l app=triage-service
kubectl logs -l app=concepts-service
kubectl logs -l app=debug-service
kubectl logs -l app=exercise-service
```

## Testing the Services

### 1. Port Forward to Access Services

```bash
# Triage Service
kubectl port-forward svc/triage-service 8000:80 &

# Concepts Service
kubectl port-forward svc/concepts-service 8001:80 &

# Debug Service
kubectl port-forward svc/debug-service 8002:80 &

# Exercise Service
kubectl port-forward svc/exercise-service 8003:80 &
```

### 2. Test Triage Service

```bash
# Send a test query to the triage service
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "test-student-1",
    "session_id": "test-session-1",
    "query": "Can you explain how Python loops work?",
    "context": {
      "current_module": "loops",
      "difficulty_level": "beginner"
    }
  }'
```

### 3. Monitor Kafka Messages

```bash
# Watch Kafka messages (requires kubectl exec into Kafka pod)
kubectl exec -n kafka learnflow-kafka-kafka-0 -- \
  /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server learnflow-kafka-kafka-bootstrap:9092 \
  --topic learning.response --from-beginning
```

## Environment-Specific Configuration

### Development Environment
- Use shorter timeouts for API calls
- Enable detailed logging
- Skip certain security checks for faster iteration

### Production Environment
- Implement proper secrets management
- Enable SSL/TLS for all communications
- Set up monitoring and alerting
- Configure resource limits and requests

## Troubleshooting

### Common Issues

1. **Dapr Sidecar Not Injected**
   - Verify Dapr is initialized in Kubernetes: `dapr status -k`
   - Check if your namespace has Dapr enabled: `kubectl get configurations.dapr.io -A`

2. **Kafka Connection Issues**
   - Verify Kafka is running: `kubectl get pods -n kafka`
   - Check Kafka bootstrap server name: `kubectl get svc -n kafka`

3. **OpenAI API Errors**
   - Verify API key is correctly set in secrets
   - Check network connectivity to OpenAI endpoints

4. **Database Connection Failures**
   - Confirm PostgreSQL is running: `kubectl get pods -n postgres`
   - Verify connection parameters in configuration

### Useful Commands

```bash
# Check Dapr sidecar status
dapr status -k

# Get detailed pod information
kubectl describe pods

# Check all services
kubectl get all

# View Dapr logs
kubectl logs -l app=dapr-placement-server
```

## Next Steps

1. Integrate with the LearnFlow frontend
2. Set up monitoring and observability
3. Implement user authentication
4. Add comprehensive tests
5. Configure CI/CD pipeline