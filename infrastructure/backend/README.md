# LearnFlow Backend Deployment

Deployment documentation for the LearnFlow backend microservices.

## Architecture Overview

The LearnFlow backend consists of 4 AI-powered microservices:
- **Triage Service**: Routes queries to appropriate specialist services
- **Concepts Service**: Explains Python programming concepts
- **Debug Service**: Helps fix code errors
- **Exercise Service**: Generates and grades exercises

## Service Descriptions

### Triage Service
- Entry point for all student queries
- Uses keyword analysis to route queries appropriately
- Publishes to Kafka topics for specialist services

### Concepts Service
- Provides explanations of Python concepts using AI
- Generates examples and best practices
- Integrates with OpenAI API

### Debug Service
- Analyzes code errors and provides corrections
- Offers debugging tips and best practices
- Integrates with OpenAI API

### Exercise Service
- Generates Python programming exercises
- Creates starter code and test cases
- Integrates with OpenAI API

## Deployment Commands

### Prerequisites
```bash
# Ensure you have the following:
# 1. Kubernetes cluster running
# 2. Dapr installed on the cluster
# 3. Kafka (Strimzi) installed
# 4. PostgreSQL installed
# 5. OpenAI API key
```

### Deploy Backend Services
```bash
# 1. Apply configurations
kubectl apply -f backend-config.yaml
kubectl apply -f backend-secrets.yaml  # Update with your API key first!

# 2. Build Docker images
eval $(minikube docker-env)
for svc in triage concepts debug exercise; do
  docker build -t ${svc}-service:latest backend/${svc}-service/
done

# 3. Deploy services
for svc in triage concepts debug exercise; do
  kubectl apply -f backend/${svc}-service/deployment.yaml
done

# 4. Wait for services to be ready
kubectl wait --for=condition=ready pod --all --timeout=300s
```

### Verification
```bash
# Check all pods
kubectl get pods | grep -E "triage|concepts|debug|exercise"

# Check all services
kubectl get svc | grep -E "triage|concepts|debug|exercise"

# Test health
kubectl port-forward svc/triage-service 8000:80
curl http://localhost:8000/health
```

## Testing Procedures

### Individual Service Tests
```bash
# Test triage service
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{"student_id":"test","session_id":"test","query":"Explain Python loops"}'

# Test health of all services
curl http://localhost:8000/health
curl http://localhost:8001/health  # concepts
curl http://localhost:8002/health  # debug
curl http://localhost:8003/health  # exercise
```

### End-to-End Test
Run the end-to-end test script:
```bash
./test-e2e.sh
```

## Troubleshooting Guide

### Common Issues

#### Issue 1: ImagePullBackOff
```bash
# Forgot to use Minikube Docker
eval $(minikube docker-env)
docker build -t <service>:latest backend/<service>/
```

#### Issue 2: OpenAI API Error
```bash
# Check secret
kubectl get secret backend-secrets -o yaml
# Verify key starts with sk-
```

#### Issue 3: Dapr Sidecar Not Injecting
```bash
# Check Dapr is installed
dapr status -k
# Check annotations in deployment.yaml
kubectl describe pod <pod-name> | grep dapr.io
```

#### Issue 4: Kafka Connection Failed
```bash
# Verify Kafka service name
kubectl get svc -n kafka
# Should be: learnflow-kafka-kafka-bootstrap
```

### Useful Commands
```bash
# View logs
kubectl logs -l app=triage-service -c triage-service
kubectl logs -l app=concepts-service -c concepts-service
kubectl logs -l app=debug-service -c debug-service
kubectl logs -l app=exercise-service -c exercise-service

# Check Dapr sidecar logs
kubectl logs -l app=triage-service -c daprd
kubectl logs -l app=concepts-service -c daprd
kubectl logs -l app=debug-service -c daprd
kubectl logs -l app=exercise-service -c daprd

# Describe pods for detailed info
kubectl describe pod -l app=triage-service
```