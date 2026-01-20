---
id: 1
title: infra-foundation
stage: spec
date: 2026-01-19
surface: agent
model: claude-sonnet-4-5-20250929
feature: infra-foundation
branch: 1-infra-foundation
user: general
command: sp.specify
labels: [infrastructure, kubernetes, kafka, postgresql, dapr]
links:
  spec: specs/1-infra-foundation/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/1-infra-foundation/spec.md
  - specs/1-infra-foundation/plan.md
  - specs/1-infra-foundation/tasks.md
  - specs/1-infra-foundation/checklists/requirements.md
tests:
  - specs/1-infra-foundation/checklists/requirements.md
---

## Prompt

Part 1: Infrastructure Foundation - Complete Specification
## LearnFlow Hackathon III

---

## 📋 Overview

**Goal:** Kubernetes cluster par complete infrastructure setup karna including:
1. **Kafka** - Event streaming for microservices communication
2. **PostgreSQL** - Database for persistent data storage
3. **Dapr** - Distributed application runtime for service mesh

**Timeline:** Week 1
**Prerequisites:** Minikube running, Helm installed, kubectl configured

---

## 🎯 Success Criteria

✅ Kafka deployed with all 9 topics created
✅ PostgreSQL deployed with complete schema
✅ Dapr installed with pub/sub and state components
✅ All services accessible within cluster
✅ Verification scripts passing
✅ Documentation complete

---

## 📁 Directory Structure (Final State)

```
learnflow-app/
├── infrastructure/
│   ├── kafka/
│   │   ├── values.yaml                      # Kafka Helm configuration
│   │   ├── topics-config.yaml               # Topic definitions
│   │   ├── create-topics.sh                 # Topic creation script
│   │   ├── verify-kafka.sh                  # Verification script
│   │   └── README.md                        # Kafka documentation
│   │
│   ├── postgres/
│   │   ├── values.yaml                      # PostgreSQL Helm configuration
│   │   ├── init-scripts/
│   │   │   ├── 01-create-databases.sql      # Database creation
│   │   │   ├── 02-create-schemas.sql        # Schema and tables
│   │   │   └── 03-seed-data.sql             # Initial test data
│   │   ├── verify-postgres.sh               # Verification script
│   │   └── README.md                        # PostgreSQL documentation
│   │
│   ├── dapr/
│   │   ├── components/
│   │   │   ├── pubsub-kafka.yaml            # Kafka pub/sub component
│   │   │   ├── statestore-postgres.yaml     # PostgreSQL state store
│   │   │   └── secretstore.yaml             # Secret management
│   │   ├── install-dapr.sh                  # Dapr installation script
│   │   ├── verify-dapr.sh                   # Verification script
│   │   └── README.md                        # Dapr documentation
│   │
│   ├── helm/                                 # (Empty for now, will use later)
│   ├── kubernetes/                           # (Empty for now, will use later)
│   │
│   └── deploy-all.sh                         # Master deployment script
│   └── verify-all.sh                         # Master verification script
│   └── README.md                             # Infrastructure overview
│
├── backend/                                   # (Keep as is - will update in Part 2-3)
├── frontend/                                  # (Keep as is - will update in Part 4-5)
├── mcp-servers/                               # (Keep as is - will update in Part 6)
├── docs/                                      # (Keep as is)
└── README.md                                  # (Keep as is)
```

---

## 🗑️ Files/Folders to Delete

**Delete these if empty:**
```bash
# Only delete if completely empty
rm -rf learnflow-app/infrastructure/dapr/*     # If empty, will recreate
rm -rf learnflow-app/infrastructure/helm/*     # If empty, will recreate
rm -rf learnflow-app/infrastructure/kubernetes/* # If empty, will recreate
```

**Keep everything else:**
- All backend services (even if incomplete)
- All frontend files
- MCP servers directory
- Skills library
- Documentation

---

# 🔧 SECTION 1: KAFKA DEPLOYMENT

## 1.1 Kafka Values Configuration

**File:** `infrastructure/kafka/values.yaml`

```yaml
# ============================================
# Kafka Configuration for LearnFlow
# Optimized for Minikube Development
# ============================================

# Number of Kafka brokers
replicaCount: 1

image:
  registry: docker.io
  repository: bitnami/kafka
  tag: 3.6.1

# Authentication (disabled for dev)
auth:
  clientProtocol: plaintext
  interBrokerProtocol: plaintext

# Kafka listeners configuration
listeners:
  client:
    protocol: PLAINTEXT
  controller:
    protocol: PLAINTEXT
  interbroker:
    protocol: PLAINTEXT
  external:
    protocol: PLAINTEXT

# Controller configuration
controller:
  replicaCount: 1

# Broker configuration
broker:
  replicaCount: 1
  persistence:
    enabled: true
    size: 5Gi
    storageClass: standard

  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi

  # Log retention
  logRetentionHours: 168  # 7 days
  logSegmentBytes: 1073741824  # 1GB

# Metrics disabled for dev
metrics:
  kafka:
    enabled: false
  jmx:
    enabled: false

# Service configuration
service:
  type: ClusterIP
  ports:
    client: 9092

# Zookeeper configuration (required for Kafka)
zookeeper:
  enabled: true
  replicaCount: 1
  persistence:
    enabled: true
    size: 2Gi
    storageClass: standard

  resources:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1Gi
```

---

## 1.2 Kafka Topics Configuration

**File:** `infrastructure/kafka/topics-config.yaml`

```yaml
# ============================================
# Kafka Topics for LearnFlow Application
# These topics handle event-driven communication
# ============================================

apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-topics-config
  namespace: kafka
data:
  topics.json: |
    {
      "topics": [
        {
          "name": "learning.query",
          "partitions": 3,
          "replication": 1,
          "config": {
            "retention.ms": "604800000",
            "segment.ms": "86400000"
          },
          "description": "Student learning queries from frontend to triage service"
        },
        {
          "name": "learning.response",
          "partitions": 3,
          "replication": 1,
          "config": {
            "retention.ms": "604800000",
            "segment.ms": "86400000"
          },
          "description": "Agent responses back to students via frontend"
        },
        {
          "name": "code.execution.request",
          "partitions": 3,
          "replication": 1,
          "config": {
            "retention.ms": "259200000",
            "segment.ms": "43200000"
          },
          "description": "Code execution requests from students (3 day retention)"
        },
        {
          "name": "code.execution.result",
          "partitions": 3,
          "replication": 1,
          "config": {
            "retention.ms": "259200000",
            "segment.ms": "43200000"
          },
          "description": "Code execution results back to students"
        },
        {
          "name": "exercise.assigned",
          "partitions": 2,
          "replication": 1,
          "config": {
            "retention.ms": "2592000000",
            "segment.ms": "86400000"
          },
          "description": "New exercises assigned to students (30 day retention)"
        },
        {
          "name": "exercise.submitted",
          "partitions": 2,
          "replication": 1,
          "config": {
            "retention.ms": "2592000000",
            "segment.ms": "86400000"
          },
          "description": "Student exercise submissions"
        },
        {
          "name": "exercise.graded",
          "partitions": 2,
          "replication": 1,
          "config": {
            "retention.ms": "2592000000",
            "segment.ms": "86400000"
          },
          "description": "Auto-graded exercise results"
        },
        {
          "name": "struggle.detected",
          "partitions": 2,
          "replication": 1,
          "config": {
            "retention.ms": "604800000",
            "segment.ms": "86400000"
          },
          "description": "Real-time alerts when students are struggling"
        },
        {
          "name": "progress.updated",
          "partitions": 2,
          "replication": 1,
          "config": {
            "retention.ms": "2592000000",
            "segment.ms": "86400000"
          },
          "description": "Student progress updates for mastery tracking"
        }
      ]
    }
```

---

## 1.3 Kafka Topic Creation Script

**File:** `infrastructure/kafka/create-topics.sh`

```bash
#!/bin/bash
# ============================================
# Kafka Topics Creation Script
# Creates all 9 LearnFlow topics
# ============================================

set -e

echo "📋 Creating Kafka topics for LearnFlow..."

# Get Kafka pod name
KAFKA_POD=$(kubectl get pods -n kafka -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}')

if [ -z "$KAFKA_POD" ]; then
    echo "❌ Kafka pod not found. Is Kafka deployed?"
    exit 1
fi

# Topic configurations
declare -A TOPICS=(
    ["learning.query"]="3:1:retention.ms=604800000"
    ["learning.response"]="3:1:retention.ms=604800000"
    ["code.execution.request"]="3:1:retention.ms=259200000"
    ["code.execution.result"]="3:1:retention.ms=259200000"
    ["exercise.assigned"]="2:1:retention.ms=2592000000"
    ["exercise.submitted"]="2:1:retention.ms=2592000000"
    ["exercise.graded"]="2:1:retention.ms=2592000000"
    ["struggle.detected"]="2:1:retention.ms=604800000"
    ["progress.updated"]="2:1:retention.ms=2592000000"
)

# Create topics
for topic in "${!TOPICS[@]}"; do
    IFS=':' read -r partitions replication config <<< "${TOPICS[$topic]}"

    echo "Creating topic: $topic (partitions=$partitions, replication=$replication)"

    kubectl exec -n kafka "$KAFKA_POD" -- kafka-topics.sh \
        --bootstrap-server localhost:9092 \
        --create \
        --topic "$topic" \
        --partitions "$partitions" \
        --replication-factor "$replication" \
        --config "$config" \
        --if-not-exists

    echo "✅ Topic $topic created"
done

echo ""
echo "✅ All topics created successfully!"
echo ""
echo "📋 Listing all topics:"
kubectl exec -n kafka "$KAFKA_POD" -- kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --list
```

---

## 1.4 Kafka Verification Script

**File:** `infrastructure/kafka/verify-kafka.sh`

```bash
#!/bin/bash
# ============================================
# Kafka Deployment Verification
# Comprehensive checks for Kafka health
# ============================================

set -e

echo "🔍 Verifying Kafka Deployment..."
echo ""

# Check namespace
if ! kubectl get namespace kafka &> /dev/null; then
    echo "❌ Kafka namespace not found"
    exit 1
fi
echo "✅ Kafka namespace exists"

# Check Kafka pods
echo "Checking Kafka pods..."
KAFKA_PODS=$(kubectl get pods -n kafka -l app.kubernetes.io/name=kafka -o json)
RUNNING_PODS=$(echo "$KAFKA_PODS" | jq '[.items[] | select(.status.phase=="Running")] | length')
TOTAL_PODS=$(echo "$KAFKA_PODS" | jq '.items | length')

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
    echo "✅ Kafka pods running ($RUNNING_PODS/$TOTAL_PODS)"
else
    echo "❌ Kafka pods not ready ($RUNNING_PODS/$TOTAL_PODS)"
    kubectl get pods -n kafka
    exit 1
fi

# Check Zookeeper pods
echo "Checking Zookeeper pods..."
ZK_PODS=$(kubectl get pods -n kafka -l app.kubernetes.io/name=zookeeper -o json)
ZK_RUNNING=$(echo "$ZK_PODS" | jq '[.items[] | select(.status.phase=="Running")] | length')
ZK_TOTAL=$(echo "$ZK_PODS" | jq '.items | length')

if [ "$ZK_RUNNING" -eq "$ZK_TOTAL" ] && [ "$ZK_TOTAL" -gt 0 ]; then
    echo "✅ Zookeeper pods running ($ZK_RUNNING/$ZK_TOTAL)"
else
    echo "❌ Zookeeper pods not ready"
    exit 1
fi

# Get service details
KAFKA_SERVICE=$(kubectl get svc -n kafka kafka -o jsonpath='{.spec.clusterIP}')
echo "✅ Kafka service: $KAFKA_SERVICE:9092"

# Test connectivity
KAFKA_POD=$(kubectl get pods -n kafka -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}')

echo "Testing Kafka connectivity..."
if kubectl exec -n kafka "$KAFKA_POD" -- kafka-topics.sh --bootstrap-server localhost:9092 --list &> /dev/null; then
    echo "✅ Kafka is accessible"
else
    echo "❌ Cannot connect to Kafka"
    exit 1
fi

# Verify topics
echo ""
echo "📋 Verifying topics..."
TOPICS=$(kubectl exec -n kafka "$KAFKA_POD" -- kafka-topics.sh --bootstrap-server localhost:9092 --list 2>/dev/null)

REQUIRED_TOPICS=(
    "learning.query"
    "learning.response"
    "code.execution.request"
    "code.execution.result"
    "exercise.assigned"
    "exercise.submitted"
    "exercise.graded"
    "struggle.detected"
    "progress.updated"
)

MISSING_TOPICS=()
for topic in "${REQUIRED_TOPICS[@]}"; do
    if echo "$TOPICS" | grep -q "^$topic$"; then
        echo "✅ $topic"
    else
        echo "❌ $topic (missing)"
        MISSING_TOPICS+=("$topic")
    fi
done

if [ ${#MISSING_TOPICS[@]} -gt 0 ]; then
    echo ""
    echo "❌ Missing topics: ${MISSING_TOPICS[*]}"
    echo "Run: ./create-topics.sh"
    exit 1
fi

echo ""
echo "✅✅✅ Kafka deployment fully verified!"
echo ""
echo "Connection details:"
echo "  Internal: kafka.kafka.svc.cluster.local:9092"
echo "  Port-forward: kubectl port-forward svc/kafka 9092:9092 -n kafka"
```

---

## 1.5 Kafka README

**File:** `infrastructure/kafka/README.md`

```markdown
# Kafka Setup for LearnFlow

Apache Kafka for event-driven microservices communication.

## Quick Start

```bash
# Deploy Kafka
cd infrastructure/kafka
./deploy-kafka.sh

# Verify deployment
./verify-kafka.sh
```

## Architecture

```
┌────────────────────────────────────────┐
│  Kafka Cluster (namespace: kafka)      │
│                                         │
│  ┌──────────┐    ┌─────────────────┐  │
│  │Zookeeper │◄──►│  Kafka Broker   │  │
│  │          │    │  - 9 topics     │  │
│  │          │    │  - Port 9092    │  │
│  └──────────┘    └─────────────────┘  │
└────────────────────────────────────────┘
```

## Topics

| Topic | Partitions | Retention | Purpose |
|-------|-----------|-----------|---------|
| `learning.query` | 3 | 7 days | Student questions |
| `learning.response` | 3 | 7 days | Agent responses |
| `code.execution.request` | 3 | 3 days | Code to execute |
| `code.execution.result` | 3 | 3 days | Execution results |
| `exercise.assigned` | 2 | 30 days | New exercises |
| `exercise.submitted` | 2 | 30 days | Student submissions |
| `exercise.graded` | 2 | 30 days | Grading results |
| `struggle.detected` | 2 | 7 days | Struggle alerts |
| `progress.updated` | 2 | 30 days | Progress tracking |

## Testing

```bash
# Terminal 1 - Consumer
kubectl exec -n kafka $KAFKA_POD -- kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic learning.query \
  --from-beginning

# Terminal 2 - Producer
kubectl exec -n kafka $KAFKA_POD -it -- kafka-console-producer.sh \
  --bootstrap-server localhost:9092 \
  --topic learning.query
```

## Connection String

Use in microservices:
```
KAFKA_BOOTSTRAP_SERVERS=kafka.kafka.svc.cluster.local:9092
```

## Troubleshooting

**Pods not starting:**
```bash
kubectl describe pod <pod-name> -n kafka
kubectl logs <pod-name> -n kafka
```

**Delete and reinstall:**
```bash
helm uninstall kafka -n kafka
kubectl delete namespace kafka
# Then redeploy
```
```

---

# 🗄️ SECTION 2: POSTGRESQL DEPLOYMENT

## 2.1 PostgreSQL Values Configuration

**File:** `infrastructure/postgres/values.yaml`

```yaml
# ============================================
# PostgreSQL Configuration for LearnFlow
# Optimized for Minikube Development
# ============================================

global:
  postgresql:
    auth:
      username: learnflow
      password: learnflow_dev_pass
      database: learnflow_db

image:
  registry: docker.io
  repository: bitnami/postgresql
  tag: 16.1.0

auth:
  enablePostgresUser: true
  postgresPassword: postgres_admin_pass
  username: learnflow
  password: learnflow_dev_pass
  database: learnflow_db

primary:
  persistence:
    enabled: true
    size: 5Gi
    storageClass: standard

  resources:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi

  # Initialize database with scripts
  initdb:
    scripts:
      01-create-databases.sql: |
        -- Create main database (already exists from auth config)
        -- Create additional databases if needed

      02-create-schemas.sql: |
        -- Connect to learnflow_db
        \c learnflow_db;

        -- Enable UUID extension
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

        -- Users table (authentication)
        CREATE TABLE IF NOT EXISTS users (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            email VARCHAR(255) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
            full_name VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            is_active BOOLEAN DEFAULT true
        );

        -- Students table
        CREATE TABLE IF NOT EXISTS students (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            grade_level VARCHAR(50),
            learning_pace VARCHAR(20) DEFAULT 'medium' CHECK (learning_pace IN ('slow', 'medium', 'fast')),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Teachers table
        CREATE TABLE IF NOT EXISTS teachers (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            subject_expertise TEXT[],
            years_experience INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Topics table (Python curriculum)
        CREATE TABLE IF NOT EXISTS topics (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            module_number INTEGER NOT NULL,
            module_name VARCHAR(100) NOT NULL,
            topic_name VARCHAR(255) NOT NULL,
            description TEXT,
            difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 5),
            prerequisites UUID[],
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Exercises table
        CREATE TABLE IF NOT EXISTS exercises (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            topic_id UUID REFERENCES topics(id),
            title VARCHAR(255) NOT NULL,
            description TEXT,
            starter_code TEXT,
            solution_code TEXT,
            test_cases JSONB,
            difficulty INTEGER CHECK (difficulty BETWEEN 1 AND 5),
            points INTEGER DEFAULT 10,
            time_limit_seconds INTEGER DEFAULT 300,
            created_by UUID REFERENCES teachers(id),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Submissions table
        CREATE TABLE IF NOT EXISTS submissions (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            student_id UUID REFERENCES students(id),
            exercise_id UUID REFERENCES exercises(id),
            code TEXT NOT NULL,
            status VARCHAR(20) CHECK (status IN ('pending', 'running', 'passed', 'failed', 'error')),
            test_results JSONB,
            execution_time_ms INTEGER,
            submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            graded_at TIMESTAMP
        );

        -- Progress table (mastery tracking)
        CREATE TABLE IF NOT EXISTS progress (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            student_id UUID REFERENCES students(id),
            topic_id UUID REFERENCES topics(id),
            mastery_score DECIMAL(5,2) DEFAULT 0.0 CHECK (mastery_score BETWEEN 0 AND 100),
            exercises_completed INTEGER DEFAULT 0,
            exercises_total INTEGER DEFAULT 0,
            quiz_scores JSONB DEFAULT '[]'::jsonb,
            code_quality_avg DECIMAL(5,2),
            streak_days INTEGER DEFAULT 0,
            last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(student_id, topic_id)
        );

        -- Chat history table
        CREATE TABLE IF NOT EXISTS chat_history (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            student_id UUID REFERENCES students(id),
            session_id UUID NOT NULL,
            message_type VARCHAR(20) CHECK (message_type IN ('student', 'agent')),
            agent_type VARCHAR(50),
            message TEXT NOT NULL,
            metadata JSONB,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Struggle alerts table
        CREATE TABLE IF NOT EXISTS struggle_alerts (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            student_id UUID REFERENCES students(id),
            teacher_id UUID REFERENCES teachers(id),
            trigger_type VARCHAR(50),
            severity VARCHAR(20) CHECK (severity IN ('low', 'medium', 'high')),
            context JSONB,
            is_resolved BOOLEAN DEFAULT false,
            resolved_at TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Create indexes for performance
        CREATE INDEX idx_users_email ON users(email);
        CREATE INDEX idx_users_role ON users(role);
        CREATE INDEX idx_students_user_id ON students(user_id);
        CREATE INDEX idx_teachers_user_id ON teachers(user_id);
        CREATE INDEX idx_exercises_topic_id ON exercises(topic_id);
        CREATE INDEX idx_submissions_student_id ON submissions(student_id);
        CREATE INDEX idx_submissions_exercise_id ON submissions(exercise_id);
        CREATE INDEX idx_progress_student_id ON progress(student_id);
        CREATE INDEX idx_progress_topic_id ON progress(topic_id);
        CREATE INDEX idx_chat_history_student_id ON chat_history(student_id);
        CREATE INDEX idx_chat_history_session_id ON chat_history(session_id);
        CREATE INDEX idx_struggle_alerts_student_id ON struggle_alerts(student_id);
        CREATE INDEX idx_struggle_alerts_teacher_id ON struggle_alerts(teacher_id);

      03-seed-data.sql: |
        \c learnflow_db;

        -- Seed Python curriculum topics
        INSERT INTO topics (module_number, module_name, topic_name, description, difficulty_level) VALUES
        (1, 'Basics', 'Variables and Data Types', 'Learn about variables, integers, strings, floats, and booleans', 1),
        (1, 'Basics', 'Input and Output', 'Using print() and input() functions', 1),
        (1, 'Basics', 'Operators', 'Arithmetic, comparison, and logical operators', 1),
        (2, 'Control Flow', 'Conditionals', 'if, elif, else statements', 2),
        (2, 'Control Flow', 'For Loops', 'Iterating with for loops', 2),
        (2, 'Control Flow', 'While Loops', 'Using while loops and break/continue', 2),
        (3, 'Data Structures', 'Lists', 'Creating and manipulating lists', 2),
        (3, 'Data Structures', 'Dictionaries', 'Working with key-value pairs', 3),
        (3, 'Data Structures', 'Tuples and Sets', 'Immutable sequences and unique collections', 3),
        (4, 'Functions', 'Defining Functions', 'Creating reusable code blocks', 3),
        (4, 'Functions', 'Parameters and Return', 'Function arguments and return values', 3),
        (4, 'Functions', 'Scope', 'Understanding local and global scope', 3),
        (5, 'OOP', 'Classes and Objects', 'Object-oriented programming basics', 4),
        (5, 'OOP', 'Inheritance', 'Creating class hierarchies', 4),
        (5, 'OOP', 'Encapsulation', 'Private attributes and methods', 4),
        (6, 'Files', 'Reading Files', 'Opening and reading text files', 3),
        (6, 'Files', 'Writing Files', 'Creating and writing to files', 3),
        (6, 'Files', 'JSON Handling', 'Working with JSON data', 4),
        (7, 'Errors', 'Try and Except', 'Handling exceptions', 3),
        (7, 'Errors', 'Exception Types', 'Common exception types', 3),
        (7, 'Errors', 'Custom Exceptions', 'Creating custom exception classes', 4),
        (8, 'Libraries', 'Installing Packages', 'Using pip and virtual environments', 3),
        (8, 'Libraries', 'Working with APIs', 'Making HTTP requests', 4),
        (8, 'Libraries', 'Popular Libraries', 'Overview of numpy, pandas, requests', 4)
        ON CONFLICT DO NOTHING;

        -- Create test admin user (password: admin123)
        INSERT INTO users (email, password_hash, role, full_name) VALUES
        ('admin@learnflow.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lk7qN8/2qN8W', 'admin', 'Admin User')
        ON CONFLICT DO NOTHING;

        -- Create test teacher (password: teacher123)
        INSERT INTO users (email, password_hash, role, full_name) VALUES
        ('teacher@learnflow.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lk7qN8/2qN8W', 'teacher', 'Mr. Rodriguez')
        ON CONFLICT DO NOTHING;

        -- Create test student (password: student123)
        INSERT INTO users (email, password_hash, role, full_name) VALUES
        ('student@learnflow.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lk7qN8/2qN8W', 'student', 'Maya Johnson')
        ON CONFLICT DO NOTHING;

service:
  type: ClusterIP
  ports:
    postgresql: 5432

metrics:
  enabled: false
```

---

## 2.2 PostgreSQL Verification Script

**File:** `infrastructure/postgres/verify-postgres.sh`

```bash
#!/bin/bash
# ============================================
# PostgreSQL Deployment Verification
# ============================================

set -e

echo "🔍 Verifying PostgreSQL Deployment..."
echo ""

# Check namespace
if ! kubectl get namespace postgres &> /dev/null; then
    echo "❌ PostgreSQL namespace not found"
    exit 1
fi
echo "✅ PostgreSQL namespace exists"

# Check PostgreSQL pod
echo "Checking PostgreSQL pod..."
POSTGRES_POD=$(kubectl get pods -n postgres -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POSTGRES_POD" ]; then
    echo "❌ PostgreSQL pod not found"
    exit 1
fi

POD_STATUS=$(kubectl get pod -n postgres "$POSTGRES_POD" -o jsonpath='{.status.phase}')
if [ "$POD_STATUS" = "Running" ]; then
    echo "✅ PostgreSQL pod running"
else
    echo "❌ PostgreSQL pod status: $POD_STATUS"
    exit 1
fi

# Check service
POSTGRES_SERVICE=$(kubectl get svc -n postgres postgresql -o jsonpath='{.spec.clusterIP}')
echo "✅ PostgreSQL service: $POSTGRES_SERVICE:5432"

# Test database connection
echo ""
echo "Testing database connection..."

DB_TEST=$(kubectl exec -n postgres "$POSTGRES_POD" -- psql -U learnflow -d learnflow_db -c "SELECT 1;" 2>&1)

if echo "$DB_TEST" | grep -q "1 row"; then
    echo "✅ Database connection successful"
else
    echo "❌ Cannot connect to database"
    exit 1
fi

# Verify tables
echo ""
echo "📋 Verifying database schema..."

REQUIRED_TABLES=(
    "users"
    "students"
    "teachers"
    "topics"
    "exercises"
    "submissions"
    "progress"
    "chat_history"
    "struggle_alerts"
)

TABLES_LIST=$(kubectl exec -n postgres "$POSTGRES_POD" -- psql -U learnflow -d learnflow_db -t -c "\dt" | awk '{print $3}' | grep -v '^$)

MISSING_TABLES=()
for table in "${REQUIRED_TABLES[@]}"; do
    if echo "$TABLES_LIST" | grep -q "^$table$"; then
        echo "✅ Table: $table"
    else
        echo "❌ Table: $table (missing)"
        MISSING_TABLES+=("$table")
    fi
done

if [ ${#MISSING_TABLES[@]} -gt 0 ]; then
    echo ""
    echo "❌ Missing tables: ${MISSING_TABLES[*]}"
    exit 1
fi

# Count seed data
echo ""
echo "📊 Checking seed data..."
TOPICS_COUNT=$(kubectl exec -n postgres "$POSTGRES_POD" -- psql -U learnflow -d learnflow_db -t -c "SELECT COUNT(*) FROM topics;" | xargs)
USERS_COUNT=$(kubectl exec -n postgres "$POSTGRES_POD" -- psql -U learnflow -d learnflow_db -t -c "SELECT COUNT(*) FROM users;" | xargs)

echo "  Topics: $TOPICS_COUNT"
echo "  Users: $USERS_COUNT"

if [ "$TOPICS_COUNT" -ge 20 ]; then
    echo "✅ Seed data present"
else
    echo "⚠️  Seed data might be incomplete"
fi

echo ""
echo "✅✅✅ PostgreSQL deployment fully verified!"
echo ""
echo "Connection details:"
echo "  Internal: postgresql.postgres.svc.cluster.local:5432"
echo "  Database: learnflow_db"
echo "  Username: learnflow"
echo "  Password: learnflow_dev_pass"
echo ""
echo "Port-forward: kubectl port-forward svc/postgresql 5432:5432 -n postgres"
```

---

## 2.3 PostgreSQL README

**File:** `infrastructure/postgres/README.md`

```markdown
# PostgreSQL Setup for LearnFlow

PostgreSQL database for persistent data storage.

## Quick Start

```bash
cd infrastructure/postgres
./deploy-postgres.sh
./verify-postgres.sh
```

## Database Schema

### Tables

| Table | Purpose |
|-------|---------|
| `users` | Authentication and user profiles |
| `students` | Student-specific data |
| `teachers` | Teacher-specific data |
| `topics` | Python curriculum topics (24 topics) |
| `exercises` | Coding challenges |
| `submissions` | Student code submissions |
| `progress` | Mastery tracking per topic |
| `chat_history` | Student-agent conversations |
| `struggle_alerts` | Teacher notifications |

### Test Users

| Email | Password | Role |
|-------|----------|------|
| admin@learnflow.com | admin123 | admin |
| teacher@learnflow.com | teacher123 | teacher |
| student@learnflow.com | student123 | student |

## Connection String

Use in microservices:
```
postgresql://learnflow:learnflow_dev_pass@postgresql.postgres.svc.cluster.local:5432/learnflow_db
```

## Testing

```bash
# Connect to database
kubectl exec -it -n postgres $POSTGRES_POD -- psql -U learnflow -d learnflow_db

# List tables
\dt

# Query topics
SELECT module_name, topic_name FROM topics ORDER BY module_number;

# Exit
\q
```

## Troubleshooting

**Check logs:**
```bash
kubectl logs -n postgres $POSTGRES_POD
```

**Reset database:**
```bash
helm uninstall postgresql -n postgres
kubectl delete pvc -n postgres data-postgresql-0
# Then redeploy
```
```

---

# 🚀 SECTION 3: DAPR DEPLOYMENT

## 3.1 Dapr Installation Script

**File:** `infrastructure/dapr/install-dapr.sh`

```bash
#!/bin/bash
# ============================================
# Dapr Installation on Kubernetes
# ============================================

set -e

echo "🚀 Installing Dapr on Kubernetes..."

# Install Dapr CLI if not present
if ! command -v dapr &> /dev/null; then
    echo "Installing Dapr CLI..."
    wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
    echo "✅ Dapr CLI installed"
else
    echo "✅ Dapr CLI already installed: $(dapr --version)"
fi

# Initialize Dapr on Kubernetes
echo "Initializing Dapr on Kubernetes..."
dapr init -k --wait --timeout 300

# Verify installation
echo ""
echo "Verifying Dapr installation..."
dapr status -k

echo ""
echo "✅ Dapr installed successfully!"
```

---

## 3.2 Dapr Kafka Pub/Sub Component

**File:** `infrastructure/dapr/components/pubsub-kafka.yaml`

```yaml
# ============================================
# Dapr Pub/Sub Component for Kafka
# Connects Dapr to Kafka for event-driven messaging
# ============================================

apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub-kafka
  namespace: default
spec:
  type: pubsub.kafka
  version: v1
  metadata:
  - name: brokers
    value: "kafka.kafka.svc.cluster.local:9092"
  - name: consumerGroup
    value: "learnflow-services"
  - name: clientID
    value: "learnflow-dapr"
  - name: authType
    value: "none"
  - name: maxMessageBytes
    value: "1024000"
  - name: consumeRetryInterval
    value: "200ms"
  - name: version
    value: "3.6.0"
scopes:
- triage-service
- concepts-service
- debug-service
- exercise-service
```

---

## 3.3 Dapr PostgreSQL State Store

**File:** `infrastructure/dapr/components/statestore-postgres.yaml`

```yaml
# ============================================
# Dapr State Store Component for PostgreSQL
# Enables state management for services
# ============================================

apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
  namespace: default
spec:
  type: state.postgresql
  version: v1
  metadata:
  - name: connectionString
    value: "host=postgresql.postgres.svc.cluster.local port=5432 user=learnflow password=learnflow_dev_pass dbname=learnflow_db sslmode=disable"
  - name: tableName
    value: "dapr_state"
  - name: metadataTableName
    value: "dapr_state_metadata"
  - name: timeoutInSeconds
    value: "30"
scopes:
- triage-service
- concepts-service
- debug-service
- exercise-service
```

---

## 3.4 Dapr Secret Store

**File:** `infrastructure/dapr/components/secretstore.yaml`

```yaml
# ============================================
# Dapr Secret Store Component
# Uses Kubernetes secrets for sensitive data
# ============================================

apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: secretstore
  namespace: default
spec:
  type: secretstores.kubernetes
  version: v1
  metadata: []
```

---

## 3.5 Dapr Verification Script

**File:** `infrastructure/dapr/verify-dapr.sh`

```bash
#!/bin/bash
# ============================================
# Dapr Installation Verification
# ============================================

set -e

echo "🔍 Verifying Dapr Installation..."
echo ""

# Check Dapr CLI
if ! command -v dapr &> /dev/null; then
    echo "❌ Dapr CLI not installed"
    exit 1
fi
echo "✅ Dapr CLI: $(dapr --version)"

# Check Dapr on Kubernetes
echo ""
echo "Checking Dapr on Kubernetes..."
DAPR_STATUS=$(dapr status -k)

if echo "$DAPR_STATUS" | grep -q "dapr-operator.*Running"; then
    echo "✅ Dapr operator running"
else
    echo "❌ Dapr operator not running"
    exit 1
fi

if echo "$DAPR_STATUS" | grep -q "dapr-sidecar-injector.*Running"; then
    echo "✅ Dapr sidecar injector running"
else
    echo "❌ Dapr sidecar injector not running"
    exit 1
fi

if echo "$DAPR_STATUS" | grep -q "dapr-placement-server.*Running"; then
    echo "✅ Dapr placement server running"
else
    echo "❌ Dapr placement server not running"
    exit 1
fi

# Check components
echo ""
echo "📋 Verifying Dapr components..."

COMPONENTS=$(kubectl get components -o json)

if echo "$COMPONENTS" | jq -e '.items[] | select(.metadata.name=="pubsub-kafka")' &> /dev/null; then
    echo "✅ Kafka pub/sub component"
else
    echo "❌ Kafka pub/sub component (missing)"
fi

if echo "$COMPONENTS" | jq -e '.items[] | select(.metadata.name=="statestore")' &> /dev/null; then
    echo "✅ PostgreSQL state store component"
else
    echo "❌ PostgreSQL state store component (missing)"
fi

if echo "$COMPONENTS" | jq -e '.items[] | select(.metadata.name=="secretstore")' &> /dev/null; then
    echo "✅ Secret store component"
else
    echo "❌ Secret store component (missing)"
fi

echo ""
echo "✅✅✅ Dapr installation fully verified!"
```

---

## 3.6 Dapr README

**File:** `infrastructure/dapr/README.md`

```markdown
# Dapr Setup for LearnFlow

Distributed Application Runtime for service-to-service communication.

## Quick Start

```bash
cd infrastructure/dapr
./install-dapr.sh
kubectl apply -f components/
./verify-dapr.sh
```

## Components

### Pub/Sub (Kafka)
- **Name:** `pubsub-kafka`
- **Type:** pubsub.kafka
- **Broker:** kafka.kafka.svc.cluster.local:9092

### State Store (PostgreSQL)
- **Name:** `statestore`
- **Type:** state.postgresql
- **Database:** learnflow_db

### Secret Store (Kubernetes)
- **Name:** `secretstore`
- **Type:** secretstores.kubernetes

## Usage in Services

### Publish Event
```python
from dapr.clients import DaprClient

with DaprClient() as d:
    d.publish_event(
        pubsub_name='pubsub-kafka',
        topic_name='learning.query',
        data={"message": "Hello"}
    )
```

### Subscribe to Event
```python
@app.subscribe(pubsub_name='pubsub-kafka', topic='learning.response')
def handle_response(event):
    print(f"Received: {event.data}")
```

### Save State
```python
from dapr.clients import DaprClient

with DaprClient() as d:
    d.save_state(
        store_name='statestore',
        key='user-123',
        value='{"name": "Maya"}'
    )
```

## Sidecar Injection

Add to deployment.yaml:
```yaml
annotations:
  dapr.io/enabled: "true"
  dapr.io/app-id: "my-service"
  dapr.io/app-port: "8000"
```

## Troubleshooting

**Check Dapr status:**
```bash
dapr status -k
```

**Check component:**
```bash
kubectl get components
kubectl describe component pubsub-kafka
```

**View logs:**
```bash
kubectl logs -l app=dapr-operator -n dapr-system
```
```

---

# 🎬 SECTION 4: MASTER DEPLOYMENT SCRIPTS

## 4.1 Deploy All Infrastructure

**File:** `infrastructure/deploy-all.sh`

```bash
#!/bin/bash
# ============================================
# Master Deployment Script
# Deploys all infrastructure components
# ============================================

set -e

echo "🚀 Deploying LearnFlow Infrastructure..."
echo ""

# Check prerequisites
echo "Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl required"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ helm required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "❌ jq required"; exit 1; }

echo "✅ Prerequisites satisfied"
echo ""

# Add Helm repos
echo "📦 Adding Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
echo ""

# Deploy Kafka
echo "═══════════════════════════════════════"
echo "1️⃣  DEPLOYING KAFKA"
echo "═══════════════════════════════════════"
cd kafka

kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -

helm install kafka bitnami/kafka \
  --namespace kafka \
  --values values.yaml \
  --wait --timeout 10m

echo "Waiting for Kafka pods..."
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=kafka \
  -n kafka --timeout=300s

echo "Creating Kafka topics..."
chmod +x create-topics.sh
./create-topics.sh

echo "Verifying Kafka..."
chmod +x verify-kafka.sh
./verify-kafka.sh

echo ""
echo "✅ Kafka deployed successfully"
echo ""

# Deploy PostgreSQL
cd ../postgres

echo "═══════════════════════════════════════"
echo "2️⃣  DEPLOYING POSTGRESQL"
echo "═══════════════════════════════════════"

kubectl create namespace postgres --dry-run=client -o yaml | kubectl apply -f -

helm install postgresql bitnami/postgresql \
  --namespace postgres \
  --values values.yaml \
  --wait --timeout 10m

echo "Waiting for PostgreSQL pod..."
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=postgresql \
  -n postgres --timeout=300s

echo "Verifying PostgreSQL..."
chmod +x verify-postgres.sh
./verify-postgres.sh

echo ""
echo "✅ PostgreSQL deployed successfully"
echo ""

# Deploy Dapr
cd ../dapr

echo "═══════════════════════════════════════"
echo "3️⃣  DEPLOYING DAPR"
echo "═══════════════════════════════════════"

chmod +x install-dapr.sh
./install-dapr.sh

echo "Applying Dapr components..."
kubectl apply -f components/

echo "Verifying Dapr..."
chmod +x verify-dapr.sh
./verify-dapr.sh

echo ""
echo "✅ Dapr deployed successfully"
echo ""

# Final summary
cd ..

echo "═══════════════════════════════════════"
echo "✅✅✅ INFRASTRUCTURE DEPLOYMENT COMPLETE"
echo "═══════════════════════════════════════"
echo ""
echo "Deployed components:"
echo "  ✅ Kafka (namespace: kafka)"
echo "  ✅ PostgreSQL (namespace: postgres)"
echo "  ✅ Dapr (namespace: dapr-system)"
echo ""
echo "Connection strings:"
echo "  Kafka: kafka.kafka.svc.cluster.local:9092"
echo "  PostgreSQL: postgresql.postgres.svc.cluster.local:5432"
echo ""
echo "Next steps:"
echo "  1. Run ./verify-all.sh to verify everything"
echo "  2. Proceed to Part 2: Backend Services"
```

---

## 4.2 Verify All Infrastructure

**File:** `infrastructure/verify-all.sh`

```bash
#!/bin/bash
# ============================================
# Master Verification Script
# Verifies all infrastructure components
# ============================================

set -e

echo "🔍 Verifying All Infrastructure Components..."
echo ""

FAILED=0

# Verify Kafka
echo "═══════════════════════════════════════"
echo "Verifying Kafka..."
echo "═══════════════════════════════════════"
cd kafka
if ./verify-kafka.sh; then
    echo "✅ Kafka verification passed"
else
    echo "❌ Kafka verification failed"
    FAILED=1
fi
echo ""

# Verify PostgreSQL
cd ../postgres
echo "═══════════════════════════════════════"
echo "Verifying PostgreSQL..."
echo "═══════════════════════════════════════"
if ./verify-postgres.sh; then
    echo "✅ PostgreSQL verification passed"
else
    echo "❌ PostgreSQL verification failed"
    FAILED=1
fi
echo ""

# Verify Dapr
cd ../dapr
echo "═══════════════════════════════════════"
echo "Verifying Dapr..."
echo "═══════════════════════════════════════"
if ./verify-dapr.sh; then
    echo "✅ Dapr verification passed"
else
    echo "❌ Dapr verification failed"
    FAILED=1
fi
echo ""

cd ..

# Final result
if [ $FAILED -eq 0 ]; then
    echo "═══════════════════════════════════════"
    echo "✅✅✅ ALL VERIFICATIONS PASSED"
    echo "═══════════════════════════════════════"
    echo ""
    echo "Infrastructure is ready!"
    echo "You can now proceed to Part 2: Backend Services"
    exit 0
else
    echo "═══════════════════════════════════════"
    echo "❌ SOME VERIFICATIONS FAILED"
    echo "═══════════════════════════════════════"
    echo ""
    echo "Please check the logs above and fix issues"
    exit 1
fi
```

---

## 4.3 Infrastructure Overview README

**File:** `infrastructure/README.md`

```markdown
# LearnFlow Infrastructure

Complete Kubernetes infrastructure for the LearnFlow platform.

## Components

1. **Kafka** - Event streaming (namespace: kafka)
2. **PostgreSQL** - Database (namespace: postgres)
3. **Dapr** - Service mesh (namespace: dapr-system)

## Quick Deploy

```bash
# Deploy everything
cd infrastructure
chmod +x deploy-all.sh
./deploy-all.sh

# Verify everything
chmod +x verify-all.sh
./verify-all.sh
```

## Individual Components

### Kafka
```bash
cd kafka
# See kafka/README.md for details
```

### PostgreSQL
```bash
cd postgres
# See postgres/README.md for details
```

### Dapr
```bash
cd dapr
# See dapr/README.md for details
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│              Kubernetes Cluster (Minikube)           │
│                                                      │
│  ┌────────────────────────────────────────────────┐│
│  │ Namespace: kafka                               ││
│  │   - Kafka Broker (1 replica)                   ││
│  │   - Zookeeper (1 replica)                      ││
│  │   - 9 Topics for LearnFlow                     ││
│  └────────────────────────────────────────────────┘│
│                                                      │
│  ┌────────────────────────────────────────────────┐│
│  │ Namespace: postgres                            ││
│  │   - PostgreSQL (1 replica)                     ││
│  │   - 9 Tables with seed data                    ││
│  └────────────────────────────────────────────────┘│
│                                                      │
│  ┌────────────────────────────────────────────────┐│
│  │ Namespace: dapr-system                         ││
│  │   - Dapr Operator                              ││
│  │   - Dapr Sidecar Injector                      ││
│  │   - Dapr Placement Server                      ││
│  │                                                 ││
│  │ Default Namespace:                             ││
│  │   - Dapr Components (3 components)             ││
│  └────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
```

## Connection Details

### Kafka
- **Internal:** `kafka.kafka.svc.cluster.local:9092`
- **Port-forward:** `kubectl port-forward svc/kafka 9092:9092 -n kafka`

### PostgreSQL
- **Internal:** `postgresql.postgres.svc.cluster.local:5432`
- **Database:** `learnflow_db`
- **Username:** `learnflow`
- **Password:** `learnflow_dev_pass`
- **Port-forward:** `kubectl port-forward svc/postgresql 5432:5432 -n postgres`

### Dapr Components
- **Pub/Sub:** `pubsub-kafka`
- **State Store:** `statestore`
- **Secret Store:** `secretstore`

## Troubleshooting

### View all pods
```bash
kubectl get pods --all-namespaces
```

### Check specific namespace
```bash
kubectl get all -n kafka
kubectl get all -n postgres
kubectl get all -n dapr-system
```

### Delete everything
```bash
helm uninstall kafka -n kafka
helm uninstall postgresql -n postgres
dapr uninstall -k
kubectl delete namespace kafka postgres
```

### Restart Minikube
```bash
minikube delete
minikube start --cpus=4 --memory=8192
# Then redeploy
```

## Next Steps

After infrastructure is deployed and verified:
1. ✅ Part 1 complete
2. → Proceed to **Part 2: Backend Services**
   - Triage Service
   - Concepts, Debug, Exercise Services
```

---

# 📝 SECTION 5: CLAUDE CODE INSTRUCTIONS

## How to Execute This Spec with Claude Code

**Open your terminal in the `learnflow-app` directory and follow these steps:**

### Step 1: Create Directory Structure

```bash
# Create all necessary directories
mkdir -p infrastructure/kafka infrastructure/postgres infrastructure/dapr/components
```

### Step 2: Use Kafka Skill (if available)

```bash
# Check if kafka-k8s-setup skill exists
ls .claude/skills/ | grep kafka

# If skill exists, use it
# If not, manually create the files from this spec
```

### Step 3: Create All Files

**Use Claude Code to create each file mentioned in this spec:**

```bash
# Example for Kafka files
claude "Create infrastructure/kafka/values.yaml with the content from Part 1 spec"
claude "Create infrastructure/kafka/topics-config.yaml from spec"
claude "Create infrastructure/kafka/create-topics.sh script from spec"
# ... and so on for all files
```

### Step 4: Deploy Infrastructure

```bash
# Make scripts executable
chmod +x infrastructure/kafka/*.sh
chmod +x infrastructure/postgres/*.sh
chmod +x infrastructure/dapr/*.sh
chmod +x infrastructure/*.sh

# Deploy everything
cd infrastructure
./deploy-all.sh
```

### Step 5: Verify Deployment

```bash
# Run master verification
./verify-all.sh

# If any component fails, check individual verifications:
cd kafka && ./verify-kafka.sh
cd ../postgres && ./verify-postgres.sh
cd ../dapr && ./verify-dapr.sh
```

---

# 🎯 SECTION 6: SKILLS TO UPDATE/CREATE

## Required Skills for Part 1

### 1. kafka-k8s-setup Skill

**Location:** `skills-library/.claude/skills/kafka-k8s-setup/`

**Update SKILL.md to use this spec:**

```markdown
---
name: kafka-k8s-setup
description: Deploy Apache Kafka on Kubernetes with custom topics
---

# Kafka Kubernetes Setup

## When to Use
- User asks to deploy Kafka
- Setting up event-driven microservices
- Need message broker for LearnFlow

## Instructions

1. Navigate to `infrastructure/kafka`
2. Deploy using Helm:
   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update
   kubectl create namespace kafka
   helm install kafka bitnami/kafka -n kafka --values values.yaml --wait
   ```
3. Create topics: `./create-topics.sh`
4. Verify: `./verify-kafka.sh`

## Validation
- [ ] All pods Running
- [ ] Can create test topic
- [ ] All 9 LearnFlow topics exist

See [REFERENCE.md](./REFERENCE.md) for troubleshooting.
```

### 2. postgres-k8s-setup Skill

**Location:** `skills-library/.claude/skills/postgres-k8s-setup/`

**Create SKILL.md:**

```markdown
---
name: postgres-k8s-setup
description: Deploy PostgreSQL on Kubernetes with schema initialization
---

# PostgreSQL Kubernetes Setup

## When to Use
- User asks to deploy PostgreSQL
- Need database for LearnFlow
- Setting up persistent storage

## Instructions

1. Navigate to `infrastructure/postgres`
2. Deploy using Helm:
   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   kubectl create namespace postgres
   helm install postgresql bitnami/postgresql -n postgres --values values.yaml --wait
   ```
3. Verify: `./verify-postgres.sh`

## Validation
- [ ] Pod Running
- [ ] All 9 tables created
- [ ] Seed data present
- [ ] Can connect to database

See [REFERENCE.md](./REFERENCE.md) for schema details.
```

### 3. dapr-k8s-setup Skill (New)

**Location:** `skills-library/.claude/skills/dapr-k8s-setup/`

**Create SKILL.md:**

```markdown
---
name: dapr-k8s-setup
description: Install Dapr on Kubernetes with components
---

# Dapr Kubernetes Setup

## When to Use
- User asks to install Dapr
- Need service mesh for microservices
- Setting up pub/sub or state management

## Instructions

1. Navigate to `infrastructure/dapr`
2. Install Dapr: `./install-dapr.sh`
3. Apply components: `kubectl apply -f components/`
4. Verify: `./verify-dapr.sh`

## Validation
- [ ] Dapr operator running
- [ ] Sidecar injector running
- [ ] All 3 components created
- [ ] Can use Dapr in services

See [REFERENCE.md](./REFERENCE.md) for component configuration.
```

---

# ✅ SECTION 7: VALIDATION CHECKLIST

## Part 1 Completion Criteria

Use this checklist to confirm Part 1 is complete:

### Infrastructure Files Created
- [ ] `infrastructure/kafka/values.yaml`
- [ ] `infrastructure/kafka/topics-config.yaml`
- [ ] `infrastructure/kafka/create-topics.sh`
- [ ] `infrastructure/kafka/verify-kafka.sh`
- [ ] `infrastructure/kafka/README.md`
- [ ] `infrastructure/postgres/values.yaml`
- [ ] `infrastructure/postgres/verify-postgres.sh`
- [ ] `infrastructure/postgres/README.md`
- [ ] `infrastructure/dapr/install-dapr.sh`
- [ ] `infrastructure/dapr/components/pubsub-kafka.yaml`
- [ ] `infrastructure/dapr/components/statestore-postgres.yaml`
- [ ] `infrastructure/dapr/components/secretstore.yaml`
- [ ] `infrastructure/dapr/verify-dapr.sh`
- [ ] `infrastructure/dapr/README.md`
- [ ] `infrastructure/deploy-all.sh`
- [ ] `infrastructure/verify-all.sh`
- [ ] `infrastructure/README.md`

### Kafka Deployment
- [ ] Kafka namespace exists
- [ ] Kafka pod(s) running
- [ ] Zookeeper pod(s) running
- [ ] All 9 topics created
- [ ] Can produce/consume messages
- [ ] verify-kafka.sh passes

### PostgreSQL Deployment
- [ ] PostgreSQL namespace exists
- [ ] PostgreSQL pod running
- [ ] All 9 tables created
- [ ] Seed data inserted (24 topics, 3 users)
- [ ] Can query database
- [ ] verify-postgres.sh passes

### Dapr Deployment
- [ ] Dapr CLI installed
- [ ] Dapr operator running
- [ ] Dapr sidecar injector running
- [ ] Dapr placement server running
- [ ] pubsub-kafka component created
- [ ] statestore component created
- [ ] secretstore component created
- [ ] verify-dapr.sh passes

### Master Verification
- [ ] deploy-all.sh executes without errors
- [ ] verify-all.sh passes all checks
- [ ] All pods in Running state
- [ ] All services accessible
- [ ] Documentation complete

---

# 🎓 SECTION 8: LEARNING OBJECTIVES

After completing Part 1, you should understand:

## Kubernetes Concepts
- Namespaces for resource isolation
- Pods, Services, and Deployments
- Persistent Volumes and Storage Classes
- ConfigMaps for configuration
- kubectl commands for cluster management

## Helm
- Helm charts and repositories
- Custom values.yaml files
- Installing and upgrading releases
- Managing application lifecycle

## Kafka
- Event-driven architecture
- Topics, partitions, and replication
- Producer and consumer patterns
- Kafka on Kubernetes considerations

## PostgreSQL
- Database schemas and tables
- Initialization scripts (initdb)
- Connection strings for services
- Running databases on Kubernetes

## Dapr
- Service mesh benefits
- Pub/Sub components
- State stores
- Sidecar pattern
- Component configuration

## Skills Development
- Writing MCP Code Execution skills
- Script-based automation
- Verification and testing patterns
- Documentation standards

---

# 🚨 SECTION 9: COMMON ISSUES & SOLUTIONS

## Issue 1: Minikube Resource Issues

**Symptom:** Pods stuck in Pending state

**Solution:**
```bash
# Check resources
minikube status

# Increase resources and restart
minikube delete
minikube start --cpus=4 --memory=8192 --driver=docker

# Redeploy
cd infrastructure
./deploy-all.sh
```

## Issue 2: Kafka Pods CrashLooping

**Symptom:** Kafka or Zookeeper pods restarting

**Solution:**
```bash
# Check logs
kubectl logs -n kafka <pod-name>

# Common fix: Delete PVCs and redeploy
helm uninstall kafka -n kafka
kubectl delete pvc -n kafka data-kafka-0 data-zookeeper-0
# Redeploy
```

## Issue 3: PostgreSQL Connection Refused

**Symptom:** Cannot connect to database

**Solution:**
```bash
# Check pod status
kubectl get pods -n postgres

# Check logs
kubectl logs -n postgres <postgres-pod>

# Test connection
kubectl exec -it -n postgres <postgres-pod> -- psql -U learnflow -d learnflow_db

# If password issues, check values.yaml
```

## Issue 4: Dapr Components Not Working

**Symptom:** Services can't use Dapr

**Solution:**
```bash
# Verify Dapr installation
dapr status -k

# Check components
kubectl get components

# Describe component for errors
kubectl describe component pubsub-kafka

# Reinstall if needed
dapr uninstall -k
./infrastructure/dapr/install-dapr.sh
kubectl apply -f infrastructure/dapr/components/
```

## Issue 5: Topics Not Created

**Symptom:** Kafka topics missing

**Solution:**
```bash
# Manually create topics
cd infrastructure/kafka
./create-topics.sh

# Or create individual topic
KAFKA_POD=$(kubectl get pods -n kafka -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n kafka $KAFKA_POD -- kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create --topic learning.query \
  --partitions 3 --replication-factor 1
```

---

# 📊 SECTION 10: SUCCESS METRICS

## How to Know Part 1 is Complete

Run these commands and verify outputs:

```bash
# 1. All namespaces exist
kubectl get namespaces | grep -E "kafka|postgres|dapr-system"
# Expected: 3 namespaces

# 2. All pods running
kubectl get pods -A | grep -v "Running\|Completed"
# Expected: Empty output (no non-running pods)

# 3. Kafka topics
KAFKA_POD=$(kubectl get pods -n kafka -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n kafka $KAFKA_POD -- kafka-topics.sh --bootstrap-server localhost:9092 --list | wc -l
# Expected: 9 or more

# 4. PostgreSQL tables
POSTGRES_POD=$(kubectl get pods -n postgres -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n postgres $POSTGRES_POD -- psql -U learnflow -d learnflow_db -c "\dt" | grep -c "table"
# Expected: 9

# 5. Dapr status
dapr status -k | grep -c "Running"
# Expected: 3 (operator, injector, placement)

# 6. Dapr components
kubectl get components | wc -l
# Expected: 4 (including header)

# 7. Master verification
cd infrastructure
./verify-all.sh
# Expected: Exit code 0 (all pass)
```

**If all above commands pass, Part 1 is ✅ COMPLETE!**

---

# 🎯 NEXT STEPS

Once Part 1 is complete:

1. **Commit your work:**
   ```bash
   git add infrastructure/
   git commit -m "Part 1: Infrastructure foundation complete - Kafka, PostgreSQL, Dapr deployed"
   git push
   ```

2. **Document completion:**
   - Take screenshots of `verify-all.sh` passing
   - Note any issues encountered and solutions
   - Update main README.md with infrastructure status

3. **Proceed to Part 2:**
   - Backend services (Triage, Concepts, Debug, Exercise)
   - Dapr integration with FastAPI
   - Kafka producers/consumers

---

# 📞 SUPPORT

If you encounter issues:

1. Check the Common Issues section above
2. Review component-specific README files
3. Check Kubernetes docs: kubernetes.io
4. Check Dapr docs: docs.dapr.io
5. Check Kafka docs: kafka.apache.org

---

**End of Part 1 Specification**

This specification covers 100% of Part 1 requirements. Use Claude Code or Goose to execute each section systematically. Good luck! 🚀

## Response snapshot

I have successfully created the infrastructure foundation specification for the LearnFlow platform. This includes:

1. **Specification file** (specs/1-infra-foundation/spec.md): Defines the user scenarios, requirements, and success criteria for deploying Kafka, PostgreSQL, and Dapr on Kubernetes.

2. **Plan file** (specs/1-infra-foundation/plan.md): Outlines the architecture decisions, technical approach, and risk mitigation strategies for the infrastructure deployment.

3. **Tasks file** (specs/1-infra-foundation/tasks.md): Details all implementation tasks organized in phases from environment preparation through validation.

4. **Requirements checklist** (specs/1-infra-foundation/checklists/requirements.md): Validates that the specification meets quality standards.

The specification covers the complete infrastructure setup including:
- Kafka deployment with 9 specific topics for microservices communication
- PostgreSQL deployment with 9 tables and seed data for the LearnFlow curriculum
- Dapr installation with pub/sub and state store components
- Master deployment and verification scripts
- Comprehensive documentation

All deliverables match the original requirements from the user's specification, providing a solid foundation for deploying the LearnFlow platform's infrastructure on Kubernetes.

## Outcome

- ✅ Impact: Established complete infrastructure specification for LearnFlow platform
- 🧪 Tests: All requirements validated through checklist
- 📁 Files: spec.md, plan.md, tasks.md, and requirements.md created
- 🔁 Next prompts: Ready to proceed with implementation of the infrastructure components
- 🧠 Reflection: The specification provides a comprehensive foundation for the LearnFlow platform's infrastructure needs, enabling event-driven microservices communication with proper data persistence and service mesh capabilities.

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): PASS
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Begin implementation of Kafka deployment tasks