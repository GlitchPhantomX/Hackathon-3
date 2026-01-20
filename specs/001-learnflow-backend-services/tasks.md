# Implementation Tasks: LearnFlow Backend Services (Part 2)

**Feature**: Backend Microservices with AI Agents
**Plan**: Part 2 - Backend Services
**Created**: 2026-01-20
**Status**: Ready for Implementation
**Prerequisites**: Part 1 Infrastructure (Kafka, PostgreSQL, Dapr) deployed and verified

---

## 📋 Overview

Implementation of 4 AI-powered microservices for LearnFlow platform:
1. **Triage Service** - Routes queries to specialists
2. **Concepts Service** - Explains Python concepts with AI
3. **Debug Service** - Helps fix code errors with AI
4. **Exercise Service** - Generates and grades exercises with AI

**Architecture:**
- FastAPI for REST APIs
- Dapr for service mesh and pub/sub
- Strimzi Kafka for event streaming
- OpenAI API for AI agents
- PostgreSQL for persistence

**Total Estimated Time:** 2-3 days

---

## 🎯 Success Criteria

- ✅ All 4 services deployed and running
- ✅ Each pod shows 2/2 containers (service + Dapr sidecar)
- ✅ Services can publish to and consume from Kafka topics
- ✅ AI agents respond correctly to test queries
- ✅ End-to-end flow works: Query → Triage → Specialist → Response
- ✅ All health checks passing
- ✅ No pods in Error/CrashLoopBackOff state

---

## Phase 0: Pre-flight Validation (CRITICAL - 15 min)

**Goal:** Verify Part 1 infrastructure is ready

### TASK-P001: Verify Infrastructure Status
- **Effort**: XS (5 min)
- **Priority**: P0 - BLOCKER
- **Dependencies**: Part 1 Complete

**Verification Commands:**
```bash
cd /c/hackathon-3/infrastructure

# Check all infrastructure pods
echo "=== Kafka Pods ==="
kubectl get pods -n kafka

# Expected: learnflow-kafka-kafka-0 (Running)

echo "=== PostgreSQL Pods ==="
kubectl get pods -n postgres

# Expected: postgresql-0 (Running)

echo "=== Dapr Pods ==="
kubectl get pods -n dapr-system

# Expected: 7 dapr pods (all Running)

echo "=== Dapr Components ==="
kubectl get components

# Expected: kafka-pubsub, postgres-statestore, local-secret-store
```

**Acceptance Criteria:**
- [ ] Kafka pod running
- [ ] PostgreSQL pod running
- [ ] 7 Dapr pods running
- [ ] 3 Dapr components configured
- [ ] No pods in Error/Pending state

**If Failed:** Go back and complete Part 1 first!

---

### TASK-P002: Verify Kafka Topics Exist
- **Effort**: XS (5 min)
- **Priority**: P0 - BLOCKER
- **Dependencies**: TASK-P001

**Verification Commands:**
```bash
export MSYS_NO_PATHCONV=1

kubectl exec -n kafka learnflow-kafka-kafka-0 -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server learnflow-kafka-kafka-bootstrap:9092 \
  --list
```

**Acceptance Criteria:**
- [ ] learning.query topic exists
- [ ] learning.response topic exists
- [ ] code.execution.request topic exists
- [ ] code.execution.result topic exists
- [ ] exercise.assigned topic exists
- [ ] exercise.submitted topic exists
- [ ] exercise.graded topic exists
- [ ] struggle.detected topic exists
- [ ] progress.updated topic exists

**If Missing Topics:** Create them using infrastructure/kafka/create-topics.sh

---

### TASK-P003: Get OpenAI API Key
- **Effort**: S (10 min)
- **Priority**: P0 - BLOCKER
- **Dependencies**: None

**Steps:**
1. Go to https://platform.openai.com/api-keys
2. Create new API key
3. Copy the key (starts with `sk-`)
4. Save it securely (you'll need it in TASK-010)

**Acceptance Criteria:**
- [ ] OpenAI API key obtained
- [ ] Key starts with `sk-`
- [ ] Key saved securely

**Note:** Free tier has rate limits. For production, use paid tier.

---

## Phase 1: Project Setup (30 min)

**Goal:** Create directory structure and foundational files

### TASK-001: Create Backend Directory Structure
- **Effort**: XS (5 min)
- **Priority**: P1
- **Dependencies**: None

**Commands:**
```bash
cd /c/hackathon-3/learnflow-app

# Create backend services directories
mkdir -p backend/{triage-service,concepts-service,debug-service,exercise-service}

# Create infrastructure backend directory
mkdir -p infrastructure/backend

# Verify structure
ls -la backend/
ls -la infrastructure/backend/
```

**Acceptance Criteria:**
- [ ] `backend/triage-service/` directory exists
- [ ] `backend/concepts-service/` directory exists
- [ ] `backend/debug-service/` directory exists
- [ ] `backend/exercise-service/` directory exists
- [ ] `infrastructure/backend/` directory exists

---

### TASK-002: Create Backend Configuration Files
- **Effort**: S (15 min)
- **Priority**: P1
- **Dependencies**: TASK-001

**Create:** `infrastructure/backend/backend-config.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: default
data:
  # Strimzi Kafka Configuration
  KAFKA_BOOTSTRAP_SERVERS: "learnflow-kafka-kafka-bootstrap.kafka.svc.cluster.local:9092"
  
  # PostgreSQL Configuration
  POSTGRES_HOST: "postgresql.postgres.svc.cluster.local"
  POSTGRES_PORT: "5432"
  POSTGRES_DB: "learnflow_db"
  POSTGRES_USER: "learnflow"
  
  # Dapr Configuration
  DAPR_GRPC_PORT: "50001"
  DAPR_HTTP_PORT: "3500"
  
  # OpenAI Configuration
  OPENAI_MODEL: "gpt-4o-mini"
  OPENAI_MAX_TOKENS: "2000"
  OPENAI_TEMPERATURE: "0.7"
  
  # Service Configuration
  LOG_LEVEL: "INFO"
  ENVIRONMENT: "development"
```

**Apply:**
```bash
kubectl apply -f infrastructure/backend/backend-config.yaml
```

**Acceptance Criteria:**
- [ ] ConfigMap created successfully
- [ ] ConfigMap contains correct Strimzi Kafka service name
- [ ] `kubectl get configmap backend-config` shows the ConfigMap

---

### TASK-003: Create Backend Secrets
- **Effort**: S (10 min)
- **Priority**: P0 - BLOCKER
- **Dependencies**: TASK-002, TASK-P003 (OpenAI key)

**Create:** `infrastructure/backend/backend-secrets.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: backend-secrets
  namespace: default
type: Opaque
stringData:
  POSTGRES_PASSWORD: "learnflow_dev_pass"
  OPENAI_API_KEY: "REPLACE_WITH_YOUR_ACTUAL_KEY"
```

**Important:** Replace `REPLACE_WITH_YOUR_ACTUAL_KEY` with your OpenAI API key from TASK-P003!

**Apply:**
```bash
# Edit the file first to add your API key!
kubectl apply -f infrastructure/backend/backend-secrets.yaml
```

**Verify:**
```bash
# Check secret exists
kubectl get secret backend-secrets

# Test OpenAI key works (optional)
kubectl run -it --rm test-openai --image=python:3.11-slim --restart=Never -- \
  bash -c "pip install openai && python -c \"
from openai import OpenAI
import os
client = OpenAI(api_key='$(kubectl get secret backend-secrets -o jsonpath='{.data.OPENAI_API_KEY}' | base64 -d)')
print('Testing OpenAI API...')
response = client.chat.completions.create(
    model='gpt-4o-mini',
    messages=[{'role': 'user', 'content': 'Say hello'}],
    max_tokens=10
)
print('✅ OpenAI API works!')
print(response.choices[0].message.content)
\""
```

**Acceptance Criteria:**
- [ ] Secret created with actual OpenAI API key
- [ ] Secret contains PostgreSQL password
- [ ] OpenAI API test passes (optional but recommended)

---

### TASK-004: Update Dapr Kafka Component for Strimzi
- **Effort**: S (5 min)
- **Priority**: P1
- **Dependencies**: TASK-002

**Update:** `infrastructure/dapr/components/pubsub-kafka.yaml`

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: kafka-pubsub
  namespace: default
spec:
  type: pubsub.kafka
  version: v1
  metadata:
  - name: brokers
    value: "learnflow-kafka-kafka-bootstrap.kafka.svc.cluster.local:9092"
  - name: consumerGroup
    value: "learnflow-backend"
  - name: clientID
    value: "learnflow-services"
  - name: authType
    value: "none"
  - name: maxMessageBytes
    value: "1048576"
  - name: consumeRetryInterval
    value: "200ms"
scopes:
- triage-service
- concepts-service
- debug-service
- exercise-service
```

**Apply:**
```bash
kubectl apply -f infrastructure/dapr/components/pubsub-kafka.yaml
```

**Acceptance Criteria:**
- [ ] Component updated with Strimzi Kafka service name
- [ ] All 4 services in scopes
- [ ] Component re-applied successfully

---

## Phase 2: Triage Service (Priority: P1 - 2 hours)

**Goal:** Implement query routing service

### TASK-050: Create Triage Service Files
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: TASK-001

**Create these files in `backend/triage-service/`:**

1. **requirements.txt**
2. **main.py** (from Part 2 spec Section 2.2)
3. **Dockerfile** (from Part 2 spec Section 2.4)
4. **deployment.yaml** (from Part 2 spec Section 2.5)
5. **README.md**

**Use the code from Part 2 specification!**

**Acceptance Criteria:**
- [ ] All 5 files created
- [ ] Code matches specification
- [ ] No syntax errors in Python code

---

### TASK-051: Build Triage Service Docker Image
- **Effort**: S (15 min)
- **Priority**: P1
- **Dependencies**: TASK-050

**Commands:**
```bash
cd /c/hackathon-3/learnflow-app

# Point Docker to Minikube
eval $(minikube docker-env)

# Build image
docker build -t triage-service:latest backend/triage-service/

# Verify image
docker images | grep triage-service
```

**Acceptance Criteria:**
- [ ] Image built successfully
- [ ] Image visible in `docker images`
- [ ] Image tagged as `latest`
- [ ] Image size reasonable (<500MB)

---

### TASK-052: Deploy Triage Service
- **Effort**: S (10 min)
- **Priority**: P1
- **Dependencies**: TASK-051, TASK-002, TASK-003, TASK-004

**Commands:**
```bash
# Deploy service
kubectl apply -f backend/triage-service/deployment.yaml

# Wait for pod to be ready
kubectl wait --for=condition=ready pod \
  -l app=triage-service \
  --timeout=120s

# Check status
kubectl get pods -l app=triage-service

# Should show: triage-service-xxx  2/2  Running
```

**Acceptance Criteria:**
- [ ] Pod deployed successfully
- [ ] Pod shows 2/2 containers (service + Dapr sidecar)
- [ ] Pod status is Running
- [ ] No errors in pod description

**Troubleshooting:**
```bash
# If pod fails
kubectl describe pod -l app=triage-service
kubectl logs -l app=triage-service -c triage-service
kubectl logs -l app=triage-service -c daprd
```

---

### TASK-053: Test Triage Service
- **Effort**: S (15 min)
- **Priority**: P1
- **Dependencies**: TASK-052

**Test 1: Health Check**
```bash
# Port-forward
kubectl port-forward svc/triage-service 8000:80

# Test health (in another terminal)
curl http://localhost:8000/health

# Expected: {"status":"healthy","service":"triage-service","timestamp":"..."}
```

**Test 2: Route to Concepts**
```bash
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "test-student",
    "session_id": "test-session",
    "query": "Can you explain how Python loops work?"
  }'

# Expected: routed_to: "concepts"
```

**Test 3: Route to Debug**
```bash
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "test-student",
    "session_id": "test-session",
    "query": "I am getting a NameError in my code"
  }'

# Expected: routed_to: "debug"
```

**Acceptance Criteria:**
- [ ] Health check returns 200 OK
- [ ] Concept query routes to "concepts"
- [ ] Debug query routes to "debug"
- [ ] Exercise query routes to "exercise"
- [ ] No errors in service logs

---

## Phase 3: Concepts Service (Priority: P1 - 2 hours)

### TASK-100: Create Concepts Service Files
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: TASK-001

**Create files in `backend/concepts-service/`** using Part 2 spec Section 3.

**Acceptance Criteria:**
- [ ] requirements.txt created
- [ ] main.py created with OpenAI integration
- [ ] Dockerfile created
- [ ] deployment.yaml created with OpenAI secret mount
- [ ] README.md created

---

### TASK-101: Build Concepts Service Docker Image
- **Effort**: S (15 min)
- **Priority**: P1
- **Dependencies**: TASK-100

**Commands:**
```bash
eval $(minikube docker-env)
docker build -t concepts-service:latest backend/concepts-service/
docker images | grep concepts-service
```

**Acceptance Criteria:**
- [ ] Image built successfully
- [ ] Image includes OpenAI dependencies

---

### TASK-102: Deploy Concepts Service
- **Effort**: S (10 min)
- **Priority**: P1
- **Dependencies**: TASK-101, TASK-003

**Commands:**
```bash
kubectl apply -f backend/concepts-service/deployment.yaml

kubectl wait --for=condition=ready pod \
  -l app=concepts-service \
  --timeout=120s

kubectl get pods -l app=concepts-service
# Should show: 2/2 Running
```

**Acceptance Criteria:**
- [ ] Pod running with 2/2 containers
- [ ] Dapr sidecar injected
- [ ] OpenAI secret mounted
- [ ] No errors in logs

---

### TASK-103: Test Concepts Service End-to-End
- **Effort**: M (20 min)
- **Priority**: P1
- **Dependencies**: TASK-052, TASK-102

**Test Flow: Triage → Kafka → Concepts → Response**

**Terminal 1 - Watch Kafka Messages:**
```bash
export MSYS_NO_PATHCONV=1

kubectl exec -n kafka learnflow-kafka-kafka-0 -- \
  /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server learnflow-kafka-kafka-bootstrap:9092 \
  --topic learning.response \
  --from-beginning
```

**Terminal 2 - Send Query:**
```bash
kubectl port-forward svc/triage-service 8000:80

curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "maya",
    "session_id": "session-001",
    "query": "What is a for loop in Python?"
  }'
```

**Expected in Terminal 1:**
- Acknowledgment message from triage
- AI explanation from concepts service (with code example)

**Acceptance Criteria:**
- [ ] Query routed through triage
- [ ] Concepts service receives message
- [ ] OpenAI generates explanation
- [ ] Response published to Kafka
- [ ] Response visible in consumer terminal

---

## Phase 4: Debug Service (Priority: P1 - 2 hours)

### TASK-150: Create Debug Service Files
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: TASK-001

**Create files in `backend/debug-service/`** using Part 2 spec Section 4.

---

### TASK-151: Build and Deploy Debug Service
- **Effort**: M (25 min)
- **Priority**: P1
- **Dependencies**: TASK-150

**Commands:**
```bash
eval $(minikube docker-env)
docker build -t debug-service:latest backend/debug-service/
kubectl apply -f backend/debug-service/deployment.yaml
kubectl wait --for=condition=ready pod -l app=debug-service --timeout=120s
```

**Acceptance Criteria:**
- [ ] Image built
- [ ] Pod running 2/2
- [ ] Health check passing

---

### TASK-152: Test Debug Service End-to-End
- **Effort**: M (20 min)
- **Priority**: P1
- **Dependencies**: TASK-151

**Test with error code:**
```bash
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "maya",
    "session_id": "session-002",
    "query": "My code is not working",
    "code": "print(x)",
    "error_message": "NameError: name x is not defined"
  }'
```

**Expected:** AI debugging response in Kafka

**Acceptance Criteria:**
- [ ] Query routed to debug
- [ ] AI analyzes error
- [ ] Corrected code returned
- [ ] Debugging tips included

---

## Phase 5: Exercise Service (Priority: P2 - 2 hours)

### TASK-200: Create Exercise Service Files
- **Effort**: M (30 min)
- **Priority**: P2
- **Dependencies**: TASK-001

**Create files in `backend/exercise-service/`**

---

### TASK-201: Build and Deploy Exercise Service
- **Effort**: M (25 min)
- **Priority**: P2
- **Dependencies**: TASK-200

**Similar to TASK-151**

**Acceptance Criteria:**
- [ ] Service deployed
- [ ] Pod running 2/2

---

### TASK-202: Test Exercise Service
- **Effort**: M (20 min)
- **Priority**: P2
- **Dependencies**: TASK-201

**Test exercise generation:**
```bash
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "maya",
    "session_id": "session-003",
    "query": "Give me a Python exercise on loops"
  }'
```

**Expected:** AI-generated exercise

**Acceptance Criteria:**
- [ ] Exercise generated
- [ ] Has code template
- [ ] Has test cases

---

## Phase 6: Integration & Validation (1 hour)

### TASK-300: Verify All Services Running
- **Effort**: S (10 min)
- **Priority**: P0
- **Dependencies**: All previous tasks

**Commands:**
```bash
echo "=== All Backend Pods ==="
kubectl get pods | grep -E "triage|concepts|debug|exercise"

# Expected:
# triage-service-xxx      2/2  Running
# concepts-service-xxx    2/2  Running
# debug-service-xxx       2/2  Running
# exercise-service-xxx    2/2  Running

echo "=== Services ==="
kubectl get svc | grep -E "triage|concepts|debug|exercise"

echo "=== Dapr Subscriptions ==="
kubectl get subscriptions
```

**Acceptance Criteria:**
- [ ] All 4 pods Running with 2/2 containers
- [ ] All 4 services created
- [ ] No errors in any pod
- [ ] Dapr sidecars healthy

---

### TASK-301: Run End-to-End Test Suite
- **Effort**: M (30 min)
- **Priority**: P1
- **Dependencies**: TASK-300

**Create:** `infrastructure/backend/test-e2e.sh`

```bash
#!/bin/bash
# End-to-end test for all services

set -e

echo "=== LearnFlow Backend E2E Tests ==="

# Port-forward triage
kubectl port-forward svc/triage-service 8000:80 &
PF_PID=$!
sleep 3

# Test 1: Concepts query
echo "Test 1: Concept explanation..."
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{"student_id":"test","session_id":"e2e-1","query":"Explain Python variables"}' \
  | grep -q "concepts" && echo "✅ Routed to concepts" || echo "❌ Failed"

# Test 2: Debug query
echo "Test 2: Debug assistance..."
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{"student_id":"test","session_id":"e2e-2","query":"Fix my error: NameError"}' \
  | grep -q "debug" && echo "✅ Routed to debug" || echo "❌ Failed"

# Test 3: Exercise query
echo "Test 3: Exercise generation..."
curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{"student_id":"test","session_id":"e2e-3","query":"Give me practice exercises"}' \
  | grep -q "exercise" && echo "✅ Routed to exercise" || echo "❌ Failed"

# Cleanup
kill $PF_PID

echo ""
echo "=== E2E Tests Complete ==="
```

**Run:**
```bash
chmod +x infrastructure/backend/test-e2e.sh
./infrastructure/backend/test-e2e.sh
```

**Acceptance Criteria:**
- [ ] All 3 tests pass
- [ ] No errors during execution
- [ ] Responses received within 5 seconds

---

### TASK-302: Create Deployment Documentation
- **Effort**: S (20 min)
- **Priority**: P2
- **Dependencies**: TASK-300

**Create:** `infrastructure/backend/README.md`

Document:
- Architecture overview
- Service descriptions
- Deployment commands
- Testing procedures
- Troubleshooting guide

**Acceptance Criteria:**
- [ ] README covers all 4 services
- [ ] Includes deployment commands
- [ ] Includes troubleshooting section

---

## 📊 Task Summary

| Phase | Tasks | Estimated Time | Priority |
|-------|-------|----------------|----------|
| Phase 0: Pre-flight | P001-P003 | 30 min | P0 |
| Phase 1: Setup | 001-004 | 45 min | P1 |
| Phase 2: Triage | 050-053 | 2 hours | P1 |
| Phase 3: Concepts | 100-103 | 2 hours | P1 |
| Phase 4: Debug | 150-152 | 2 hours | P1 |
| Phase 5: Exercise | 200-202 | 2 hours | P2 |
| Phase 6: Integration | 300-302 | 1 hour | P1 |
| **TOTAL** | **27 tasks** | **~10 hours** | **Mixed** |

---

## 🎯 Critical Path

**Must complete in order:**
1. Phase 0 (Pre-flight) → Blocks everything
2. Phase 1 (Setup) → Blocks all services
3. Phase 2 (Triage) → Required for testing other services
4. Phase 3-5 (Services) → Can be done in parallel
5. Phase 6 (Integration) → Final validation

**Parallel opportunities:**
- TASK-100, TASK-150, TASK-200 (create files)
- TASK-101, TASK-151, TASK-201 (build images)
- TASK-102, TASK-151, TASK-201 (deploy services - after Triage)

---

## ⚠️ Common Issues & Solutions

**Issue 1: ImagePullBackOff**
```bash
# Forgot to use Minikube Docker
eval $(minikube docker-env)
docker build -t <service>:latest backend/<service>/
```

**Issue 2: OpenAI API Error**
```bash
# Check secret
kubectl get secret backend-secrets -o yaml
# Verify key starts with sk-
```

**Issue 3: Dapr Sidecar Not Injecting**
```bash
# Check Dapr is installed
dapr status -k
# Check annotations in deployment.yaml
kubectl describe pod <pod-name> | grep dapr.io
```

**Issue 4: Kafka Connection Failed**
```bash
# Verify Kafka service name
kubectl get svc -n kafka
# Should be: learnflow-kafka-kafka-bootstrap
```

---

## 📝 Quick Start Commands

```bash
# Complete Part 2 deployment in one go:

cd /c/hackathon-3/learnflow-app

# 1. Create structure
mkdir -p backend/{triage,concepts,debug,exercise}-service
mkdir -p infrastructure/backend

# 2. Apply configs
kubectl apply -f infrastructure/backend/backend-config.yaml
kubectl apply -f infrastructure/backend/backend-secrets.yaml  # Edit first!

# 3. Build all images
eval $(minikube docker-env)
for svc in triage concepts debug exercise; do
  docker build -t ${svc}-service:latest backend/${svc}-service/
done

# 4. Deploy all services
for svc in triage concepts debug exercise; do
  kubectl apply -f backend/${svc}-service/deployment.yaml
done

# 5. Wait and verify
kubectl wait --for=condition=ready pod --all --timeout=300s
kubectl get pods

# 6. Test
kubectl port-forward svc/triage-service 8000:80
curl http://localhost:8000/health
```

---

**End of Part 2 Tasks Document**