# Implementation Tasks: Infrastructure Foundation

**Feature**: Infrastructure Foundation (Part 1)
**Plan**: [specs/1-infra-foundation/plan.md](../1-infra-foundation/plan.md)
**Created**: 2026-01-19
**Last Updated**: 2026-01-19
**Status**: Ready for Implementation

---

## 📋 Overview

This task breakdown implements **Part 1: Infrastructure Foundation** from the LearnFlow Hackathon III project. The goal is to deploy Kafka, PostgreSQL, and Dapr on a Kubernetes cluster (Minikube) with complete automation and verification.

**Total Tasks**: 27
**Estimated Duration**: 1 week
**Prerequisites**: Minikube running, Helm installed, kubectl configured

---

## 🎯 Success Criteria

- ✅ Kafka deployed with all 9 topics created
- ✅ PostgreSQL deployed with complete schema (9 tables) and seed data
- ✅ Dapr installed with 3 components configured
- ✅ All services accessible within cluster
- ✅ All verification scripts passing
- ✅ Complete documentation created
- ✅ Skills library updated

---

## Phase 1: Environment Preparation (Priority: Critical)

### TASK-001: Create Infrastructure Directory Structure
- **Effort**: XS (5 min)
- **Priority**: P0 - Blocker
- **Dependencies**: None
- **Owner**: Developer
- **Description**: Create the complete infrastructure directory structure with all subdirectories needed for Kafka, PostgreSQL, and Dapr configurations.

**Acceptance Criteria**:
  - [x] `infrastructure/` directory exists in learnflow-app root
  - [x] `infrastructure/kafka/` directory created
  - [x] `infrastructure/postgres/` directory created
  - [x] `infrastructure/postgres/init-scripts/` directory created
  - [x] `infrastructure/dapr/` directory created
  - [x] `infrastructure/dapr/components/` subdirectory created
  - [x] All directories have proper permissions (755)

**Test Method**: 
```bash
cd learnflow-app
ls -la infrastructure/
ls -la infrastructure/kafka/
ls -la infrastructure/postgres/
ls -la infrastructure/postgres/init-scripts/
ls -la infrastructure/dapr/
ls -la infrastructure/dapr/components/
```

**Implementation Notes**:
```bash
mkdir -p infrastructure/{kafka,postgres/init-scripts,dapr/components}
```

---

### TASK-002: Verify Prerequisites and Tools
- **Effort**: XS (10 min)
- **Priority**: P0 - Blocker
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Verify that all required CLI tools are installed and properly configured. Install missing tools if needed.

**Acceptance Criteria**:
  - [x] `kubectl` version >= 1.28 is available
  - [x] `helm` version >= 3.12 is available
  - [x] `jq` version >= 1.6 is available
  - [x] `minikube` is running with minimum resources (4 CPU, 8GB RAM)
  - [x] Kubectl can connect to Minikube cluster
  - [x] Create verification script `infrastructure/check-prerequisites.sh`

**Test Method**: 
```bash
kubectl version --client
helm version
jq --version
minikube status
kubectl cluster-info
./infrastructure/check-prerequisites.sh
```

**Implementation Notes**:
Create a comprehensive check script that validates all prerequisites and provides installation instructions for missing tools.

---

### TASK-003: Clean Up Unused Directories
- **Effort**: XS (5 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Remove empty or unused infrastructure directories to avoid confusion.

**Acceptance Criteria**:
  - [x] Empty `infrastructure/helm/` removed (if exists and empty)
  - [x] Empty `infrastructure/kubernetes/` removed (if exists and empty)
  - [x] Verification that no important files were deleted
  - [x] Git status shows only intended deletions

**Test Method**: 
```bash
git status
ls infrastructure/
```

**Implementation Notes**:
```bash
# Only if directories are empty
rm -rf infrastructure/helm infrastructure/kubernetes
```

---

## Phase 2: Kafka Deployment (Priority: High)

### TASK-004: Create Kafka Helm Values Configuration
- **Effort**: S (20 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create comprehensive Helm values file for Kafka deployment optimized for Minikube development environment.

**Acceptance Criteria**:
  - [x] File `infrastructure/kafka/values.yaml` created
  - [x] Kafka broker configured with 1 replica (dev environment)
  - [x] Zookeeper configured with 1 replica
  - [x] Persistence enabled with 5Gi storage
  - [x] Resource limits defined (CPU: 1000m, Memory: 2Gi)
  - [x] Resource requests defined (CPU: 500m, Memory: 1Gi)
  - [x] Authentication disabled (plaintext for dev)
  - [x] Log retention set to 7 days
  - [x] YAML syntax is valid

**Test Method**: 
```bash
cat infrastructure/kafka/values.yaml
yamllint infrastructure/kafka/values.yaml
helm template kafka bitnami/kafka -f infrastructure/kafka/values.yaml --dry-run
```

**Implementation Notes**:
Refer to Part 1 spec Section 1.1 for complete values.yaml content.

---

### TASK-005: Create Kafka Topics Configuration
- **Effort**: S (15 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create ConfigMap defining all 9 LearnFlow Kafka topics with appropriate partitions, replication, and retention settings.

**Acceptance Criteria**:
  - [x] File `infrastructure/kafka/topics-config.yaml` created
  - [x] All 9 required topics defined:
    - [x] learning.query (3 partitions, 7-day retention)
    - [x] learning.response (3 partitions, 7-day retention)
    - [x] code.execution.request (3 partitions, 3-day retention)
    - [x] code.execution.result (3 partitions, 3-day retention)
    - [x] exercise.assigned (2 partitions, 30-day retention)
    - [x] exercise.submitted (2 partitions, 30-day retention)
    - [x] exercise.graded (2 partitions, 30-day retention)
    - [x] struggle.detected (2 partitions, 7-day retention)
    - [x] progress.updated (2 partitions, 30-day retention)
  - [x] Each topic has description field
  - [x] YAML syntax is valid

**Test Method**: 
```bash
cat infrastructure/kafka/topics-config.yaml
yamllint infrastructure/kafka/topics-config.yaml
kubectl apply --dry-run=client -f infrastructure/kafka/topics-config.yaml
```

**Implementation Notes**:
Refer to Part 1 spec Section 1.2 for complete topics configuration.

---

### TASK-006: Create Kafka Topic Creation Script
- **Effort**: S (20 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create automated bash script to create all 9 Kafka topics with proper error handling and verification.

**Acceptance Criteria**:
  - [x] File `infrastructure/kafka/create-topics.sh` created and executable (chmod +x)
  - [x] Script gets Kafka pod name dynamically
  - [x] Script creates all 9 topics with correct configuration
  - [x] Script handles "already exists" errors gracefully
  - [x] Script verifies topic creation by listing all topics
  - [x] Script provides clear output messages (✓ for success)
  - [x] Script exits with code 0 on success, 1 on failure

**Test Method**: 
```bash
chmod +x infrastructure/kafka/create-topics.sh
bash -n infrastructure/kafka/create-topics.sh  # Syntax check
# (Will execute after Kafka is deployed)
```

**Implementation Notes**:
Refer to Part 1 spec Section 1.3 for complete script content.

---

### TASK-007: Create Kafka Verification Script
- **Effort**: S (25 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create comprehensive verification script that checks all aspects of Kafka deployment health.

**Acceptance Criteria**:
  - [x] File `infrastructure/kafka/verify-kafka.sh` created and executable
  - [x] Script verifies Kafka namespace exists
  - [x] Script verifies Kafka pods are Running
  - [x] Script verifies Zookeeper pods are Running
  - [x] Script verifies Kafka service exists and has ClusterIP
  - [x] Script tests Kafka connectivity
  - [x] Script verifies all 9 topics exist
  - [x] Script provides detailed output with ✓/✗ for each check
  - [x] Script exits with code 0 only if ALL checks pass

**Test Method**: 
```bash
chmod +x infrastructure/kafka/verify-kafka.sh
bash -n infrastructure/kafka/verify-kafka.sh  # Syntax check
# (Will execute after Kafka is deployed)
```

**Implementation Notes**:
Refer to Part 1 spec Section 1.4 for complete script content. Use `jq` for JSON parsing.

---

### TASK-008: Create Kafka Documentation
- **Effort**: S (20 min)
- **Priority**: P2 - Medium
- **Dependencies**: TASK-004, TASK-005, TASK-006, TASK-007
- **Owner**: Developer
- **Description**: Create comprehensive README documenting Kafka setup, usage, and troubleshooting.

**Acceptance Criteria**:
  - [x] File `infrastructure/kafka/README.md` created
  - [x] Includes quick start deployment commands
  - [x] Includes architecture diagram (ASCII art)
  - [x] Documents all 9 topics with purpose and retention
  - [x] Provides connection string for services
  - [x] Includes testing instructions (producer/consumer examples)
  - [x] Includes troubleshooting section
  - [x] Markdown syntax is valid

**Test Method**: 
```bash
cat infrastructure/kafka/README.md
# Verify markdown rendering in editor
```

**Implementation Notes**:
Refer to Part 1 spec Section 1.5 for complete README content.

---

### TASK-009: Deploy Kafka to Kubernetes
- **Effort**: M (30 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-002, TASK-004, TASK-005
- **Owner**: Developer
- **Description**: Execute Helm deployment of Kafka using custom values file. Wait for pods to be ready.

**Acceptance Criteria**:
  - [x] Bitnami Helm repository added
  - [x] Kafka namespace created
  - [x] Kafka Helm chart installed successfully
  - [x] Kafka broker pod reaches Running state
  - [x] Zookeeper pod reaches Running state
  - [x] Kafka service is created and accessible
  - [x] All pods pass readiness probes
  - [x] No error events in pod descriptions

**Test Method**: 
```bash
kubectl get pods -n kafka
kubectl get svc -n kafka
kubectl describe pod -n kafka <kafka-pod-name>
helm list -n kafka
```

**Implementation Commands**:
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
kubectl create namespace kafka
helm install kafka bitnami/kafka \
  --namespace kafka \
  --values infrastructure/kafka/values.yaml \
  --wait --timeout 10m
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=kafka \
  -n kafka --timeout=300s
```

**Rollback Plan**:
```bash
helm uninstall kafka -n kafka
kubectl delete namespace kafka
```

---

### TASK-010: Create and Verify Kafka Topics
- **Effort**: S (15 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-009, TASK-006, TASK-007
- **Owner**: Developer
- **Description**: Execute topic creation script and verify all topics are created successfully.

**Acceptance Criteria**:
  - [x] Topic creation script executes without errors
  - [x] All 9 topics are created
  - [x] Topics have correct partition counts
  - [x] Topics have correct retention settings
  - [x] Verification script passes all checks
  - [x] Can produce and consume test messages

**Test Method**: 
```bash
cd infrastructure/kafka
./create-topics.sh
./verify-kafka.sh
# Manual topic check
kubectl exec -n kafka <kafka-pod> -- kafka-topics.sh \
  --bootstrap-server localhost:9092 --list
```

**Implementation Notes**:
If any topic creation fails, check Kafka logs and retry.

---

## Phase 3: PostgreSQL Deployment (Priority: High)

### TASK-011: Create PostgreSQL Helm Values with Init Scripts
- **Effort**: M (40 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create comprehensive Helm values file including PostgreSQL configuration and all database initialization scripts embedded.

**Acceptance Criteria**:
  - [x] File `infrastructure/postgres/values.yaml` created
  - [x] PostgreSQL 16.x image configured
  - [x] Authentication credentials defined (username: learnflow, password: learnflow_dev_pass)
  - [x] Database name set to `learnflow_db`
  - [x] Persistence enabled with 5Gi storage
  - [x] Resource limits defined
  - [x] Init script `01-create-databases.sql` embedded
  - [x] Init script `02-create-schemas.sql` with all 9 tables embedded
  - [x] Init script `03-seed-data.sql` with test data embedded
  - [x] YAML syntax is valid

**Test Method**: 
```bash
cat infrastructure/postgres/values.yaml
yamllint infrastructure/postgres/values.yaml
helm template postgresql bitnami/postgresql -f infrastructure/postgres/values.yaml --dry-run
```

**Implementation Notes**:
Refer to Part 1 spec Section 2.1 for complete values.yaml content including all SQL scripts.

**Database Schema (9 Tables)**:
1. users (authentication)
2. students
3. teachers
4. topics (24 Python curriculum topics)
5. exercises
6. submissions
7. progress (mastery tracking)
8. chat_history
9. struggle_alerts

---

### TASK-012: Create PostgreSQL Verification Script
- **Effort**: S (25 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create comprehensive verification script for PostgreSQL deployment and schema.

**Acceptance Criteria**:
  - [x] File `infrastructure/postgres/verify-postgres.sh` created and executable
  - [x] Script verifies PostgreSQL namespace exists
  - [x] Script verifies PostgreSQL pod is Running
  - [x] Script verifies service exists
  - [x] Script tests database connection
  - [x] Script verifies all 9 tables exist
  - [x] Script checks seed data count (24 topics, 3 users)
  - [x] Script provides detailed output with ✓/✗
  - [x] Script exits with code 0 only if ALL checks pass

**Test Method**: 
```bash
chmod +x infrastructure/postgres/verify-postgres.sh
bash -n infrastructure/postgres/verify-postgres.sh
```

**Implementation Notes**:
Refer to Part 1 spec Section 2.2 for complete script content.

---

### TASK-013: Create PostgreSQL Documentation
- **Effort**: S (20 min)
- **Priority**: P2 - Medium
- **Dependencies**: TASK-011, TASK-012
- **Owner**: Developer
- **Description**: Create comprehensive README for PostgreSQL setup and usage.

**Acceptance Criteria**:
  - [x] File `infrastructure/postgres/README.md` created
  - [x] Includes quick start commands
  - [x] Documents all 9 tables and purposes
  - [x] Lists test users (admin, teacher, student) with passwords
  - [x] Provides connection string format
  - [x] Includes testing instructions (psql commands)
  - [x] Includes troubleshooting section
  - [x] Markdown syntax is valid

**Test Method**: 
```bash
cat infrastructure/postgres/README.md
```

**Implementation Notes**:
Refer to Part 1 spec Section 2.3 for complete README content.

---

### TASK-014: Deploy PostgreSQL to Kubernetes
- **Effort**: M (30 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-002, TASK-011
- **Owner**: Developer
- **Description**: Execute Helm deployment of PostgreSQL with initialization scripts.

**Acceptance Criteria**:
  - [x] PostgreSQL namespace created
  - [x] PostgreSQL Helm chart installed successfully
  - [x] PostgreSQL pod reaches Running state
  - [x] Database initialized with schema
  - [x] Seed data inserted successfully
  - [x] Service is created and accessible
  - [x] Pod passes readiness probe

**Test Method**: 
```bash
kubectl get pods -n postgres
kubectl get svc -n postgres
kubectl logs -n postgres <postgres-pod> | grep "database system is ready"
```

**Implementation Commands**:
```bash
kubectl create namespace postgres
helm install postgresql bitnami/postgresql \
  --namespace postgres \
  --values infrastructure/postgres/values.yaml \
  --wait --timeout 10m
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=postgresql \
  -n postgres --timeout=300s
```

**Rollback Plan**:
```bash
helm uninstall postgresql -n postgres
kubectl delete pvc -n postgres data-postgresql-0
kubectl delete namespace postgres
```

---

### TASK-015: Verify PostgreSQL Schema and Data
- **Effort**: S (15 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-014, TASK-012
- **Owner**: Developer
- **Description**: Execute verification script and manually verify database schema.

**Acceptance Criteria**:
  - [x] Verification script passes all checks
  - [x] All 9 tables exist
  - [x] At least 24 topics in `topics` table
  - [x] At least 3 users in `users` table
  - [x] Can connect with test credentials
  - [x] All indexes created successfully

**Test Method**: 
```bash
cd infrastructure/postgres
./verify-postgres.sh

# Manual verification
kubectl exec -it -n postgres <postgres-pod> -- psql -U learnflow -d learnflow_db
\dt
SELECT COUNT(*) FROM topics;
SELECT COUNT(*) FROM users;
\q
```

---

## Phase 4: Dapr Deployment (Priority: High)

### TASK-016: Create Dapr Installation Script
- **Effort**: S (20 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create script to install Dapr CLI and initialize Dapr on Kubernetes.

**Acceptance Criteria**:
  - [x] File `infrastructure/dapr/install-dapr.sh` created and executable
  - [x] Script checks if Dapr CLI is installed
  - [x] Script installs Dapr CLI if missing
  - [x] Script initializes Dapr on Kubernetes
  - [x] Script verifies Dapr installation
  - [x] Script provides clear output messages

**Test Method**: 
```bash
chmod +x infrastructure/dapr/install-dapr.sh
bash -n infrastructure/dapr/install-dapr.sh
```

**Implementation Notes**:
Refer to Part 1 spec Section 3.1 for complete script content.

---

### TASK-017: Create Dapr Component Configurations
- **Effort**: S (30 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create all 3 Dapr component YAML files for Kafka pub/sub, PostgreSQL state store, and Kubernetes secrets.

**Acceptance Criteria**:
  - [x] File `infrastructure/dapr/components/pubsub-kafka.yaml` created
    - [x] Connects to kafka.kafka.svc.cluster.local:9092
    - [x] Uses pubsub.kafka component type
    - [x] Scoped to LearnFlow services
  - [x] File `infrastructure/dapr/components/statestore-postgres.yaml` created
    - [x] Connects to PostgreSQL service
    - [x] Uses state.postgresql component type
    - [x] Defines state and metadata tables
  - [x] File `infrastructure/dapr/components/secretstore.yaml` created
    - [x] Uses secretstores.kubernetes type
  - [x] All YAML files have valid syntax

**Test Method**: 
```bash
yamllint infrastructure/dapr/components/*.yaml
kubectl apply --dry-run=client -f infrastructure/dapr/components/
```

**Implementation Notes**:
Refer to Part 1 spec Sections 3.2, 3.3, 3.4 for complete component configurations.

---

### TASK-018: Create Dapr Verification Script
- **Effort**: S (20 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-001
- **Owner**: Developer
- **Description**: Create comprehensive verification script for Dapr installation and components.

**Acceptance Criteria**:
  - [x] File `infrastructure/dapr/verify-dapr.sh` created and executable
  - [x] Script verifies Dapr CLI is installed
  - [x] Script verifies Dapr control plane is running (operator, sidecar-injector, placement-server)
  - [x] Script verifies all 3 components are configured
  - [x] Script provides detailed output with ✓/✗
  - [x] Script exits with code 0 only if ALL checks pass

**Test Method**: 
```bash
chmod +x infrastructure/dapr/verify-dapr.sh
bash -n infrastructure/dapr/verify-dapr.sh
```

**Implementation Notes**:
Refer to Part 1 spec Section 3.5 for complete script content.

---

### TASK-019: Create Dapr Documentation
- **Effort**: S (20 min)
- **Priority**: P2 - Medium
- **Dependencies**: TASK-016, TASK-017, TASK-018
- **Owner**: Developer
- **Description**: Create comprehensive README for Dapr setup and usage.

**Acceptance Criteria**:
  - [x] File `infrastructure/dapr/README.md` created
  - [x] Includes quick start commands
  - [x] Documents all 3 components and purposes
  - [x] Provides usage examples for services (publish/subscribe, state management)
  - [x] Explains sidecar injection annotations
  - [x] Includes troubleshooting section
  - [x] Markdown syntax is valid

**Test Method**: 
```bash
cat infrastructure/dapr/README.md
```

**Implementation Notes**:
Refer to Part 1 spec Section 3.6 for complete README content.

---

### TASK-020: Install Dapr and Apply Components
- **Effort**: M (30 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-002, TASK-009, TASK-014, TASK-016, TASK-017
- **Owner**: Developer
- **Description**: Execute Dapr installation and apply all component configurations.

**Acceptance Criteria**:
  - [x] Dapr CLI installed successfully
  - [x] Dapr initialized on Kubernetes cluster
  - [x] Dapr control plane pods running (dapr-operator, dapr-sidecar-injector, dapr-placement-server)
  - [x] All 3 Dapr components applied successfully
  - [x] Components are in `default` namespace
  - [x] Dapr status shows all services healthy

**Test Method**: 
```bash
dapr --version
dapr status -k
kubectl get pods -n dapr-system
kubectl get components
```

**Implementation Commands**:
```bash
cd infrastructure/dapr
./install-dapr.sh
kubectl apply -f components/
```

**Rollback Plan**:
```bash
dapr uninstall -k
kubectl delete components --all
```

---

### TASK-021: Verify Dapr Installation
- **Effort**: S (10 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-020, TASK-018
- **Owner**: Developer
- **Description**: Execute Dapr verification script to confirm complete installation.

**Acceptance Criteria**:
  - [x] Verification script passes all checks
  - [x] All Dapr control plane components running
  - [x] All 3 components configured correctly
  - [x] No errors in Dapr operator logs

**Test Method**: 
```bash
cd infrastructure/dapr
./verify-dapr.sh
kubectl logs -l app=dapr-operator -n dapr-system --tail=50
```

---

## Phase 5: Master Scripts and Integration (Priority: Critical)

### TASK-022: Create Master Deployment Script
- **Effort**: M (40 min)
- **Priority**: P0 - Blocker
- **Dependencies**: TASK-004, TASK-006, TASK-007, TASK-011, TASK-012, TASK-016, TASK-017, TASK-018
- **Owner**: Developer
- **Description**: Create comprehensive master script that deploys all infrastructure components in the correct sequence with error handling.

**Acceptance Criteria**:
  - [x] File `infrastructure/deploy-all.sh` created and executable
  - [x] Script checks prerequisites before starting
  - [x] Script adds Helm repositories
  - [x] Script deploys Kafka with verification
  - [x] Script deploys PostgreSQL with verification
  - [x] Script installs Dapr with verification
  - [x] Script applies all Dapr components
  - [x] Script provides clear progress output
  - [x] Script stops on any error
  - [x] Script provides final summary

**Test Method**: 
```bash
chmod +x infrastructure/deploy-all.sh
bash -n infrastructure/deploy-all.sh
# Will execute in TASK-025
```

**Implementation Notes**:
Refer to Part 1 spec Section 4.1 for complete script content.

---

### TASK-023: Create Master Verification Script
- **Effort**: S (25 min)
- **Priority**: P0 - Blocker
- **Dependencies**: TASK-007, TASK-012, TASK-018
- **Owner**: Developer
- **Description**: Create master verification script that runs all component verifications and provides aggregate results.

**Acceptance Criteria**:
  - [x] File `infrastructure/verify-all.sh` created and executable
  - [x] Script runs Kafka verification
  - [x] Script runs PostgreSQL verification
  - [x] Script runs Dapr verification
  - [x] Script tracks pass/fail for each component
  - [x] Script provides final aggregate result
  - [x] Script exits with code 0 only if ALL verifications pass
  - [x] Script provides clear summary output

**Test Method**: 
```bash
chmod +x infrastructure/verify-all.sh
bash -n infrastructure/verify-all.sh
# Will execute in TASK-025
```

**Implementation Notes**:
Refer to Part 1 spec Section 4.2 for complete script content.

---

### TASK-024: Create Infrastructure Overview Documentation
- **Effort**: M (30 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-008, TASK-013, TASK-019
- **Owner**: Developer
- **Description**: Create main infrastructure README with architecture overview and quick reference.

**Acceptance Criteria**:
  - [x] File `infrastructure/README.md` created
  - [x] Includes overview of all 3 components
  - [x] Includes architecture diagram (ASCII art)
  - [x] Provides quick deploy instructions
  - [x] Lists connection details for all services
  - [x] Links to component-specific READMEs
  - [x] Includes troubleshooting section
  - [x] Documents next steps (Part 2)
  - [x] Markdown syntax is valid

**Test Method**: 
```bash
cat infrastructure/README.md
```

**Implementation Notes**:
Refer to Part 1 spec Section 4.3 for complete README content.

---

## Phase 6: Skills Library Updates (Priority: Medium)

### TASK-025: Update kafka-k8s-setup Skill
- **Effort**: S (20 min)
- **Priority**: P2 - Medium
- **Dependencies**: TASK-009, TASK-010
- **Owner**: Developer
- **Description**: Update existing Kafka skill to reflect the new deployment procedure.

**Acceptance Criteria**:
  - [x] File `skills-library/.claude/skills/kafka-k8s-setup/SKILL.md` updated
  - [x] SKILL.md references new values.yaml location
  - [x] Instructions match actual deployment commands
  - [x] Includes verification step
  - [x] REFERENCE.md updated with troubleshooting
  - [x] Skill can be executed by Claude Code successfully

**Test Method**: 
```bash
# Test with Claude Code
claude "Use kafka-k8s-setup skill to verify Kafka deployment"
```

**Implementation Notes**:
Refer to Part 1 spec Section 6.1 for skill template.

---

### TASK-026: Create postgres-k8s-setup Skill
- **Effort**: S (25 min)
- **Priority**: P2 - Medium
- **Dependencies**: TASK-014, TASK-015
- **Owner**: Developer
- **Description**: Create new skill for PostgreSQL deployment.

**Acceptance Criteria**:
  - [x] Directory `skills-library/.claude/skills/postgres-k8s-setup/` created
  - [x] File `SKILL.md` created with deployment instructions
  - [x] File `REFERENCE.md` created with schema documentation
  - [x] `scripts/` directory created if needed
  - [x] Skill can be executed by Claude Code successfully

**Test Method**: 
```bash
# Test with Claude Code
claude "Use postgres-k8s-setup skill to deploy PostgreSQL"
```

**Implementation Notes**:
Refer to Part 1 spec Section 6.2 for skill template.

---

### TASK-027: Create dapr-k8s-setup Skill
- **Effort**: S (25 min)
- **Priority**: P2 - Medium
- **Dependencies**: TASK-020, TASK-021
- **Owner**: Developer
- **Description**: Create new skill for Dapr installation.

**Acceptance Criteria**:
  - [x] Directory `skills-library/.claude/skills/dapr-k8s-setup/` created
  - [x] File `SKILL.md` created with installation instructions
  - [x] File `REFERENCE.md` created with component documentation
  - [x] `scripts/` directory created if needed
  - [x] Skill can be executed by Claude Code successfully

**Test Method**: 
```bash
# Test with Claude Code
claude "Use dapr-k8s-setup skill to install Dapr"
```

**Implementation Notes**:
Refer to Part 1 spec Section 6.3 for skill template.

---

## Phase 7: Final Validation (Priority: Critical)

### TASK-028: Execute Full Infrastructure Deployment
- **Effort**: L (60 min)
- **Priority**: P0 - Blocker
- **Dependencies**: TASK-022, TASK-023
- **Owner**: Developer
- **Description**: Execute complete infrastructure deployment using master script and verify all components.

**Acceptance Criteria**:
  - [x] Master deployment script completes without errors
  - [x] All Kafka pods running
  - [x] All PostgreSQL pods running
  - [x] All Dapr control plane pods running
  - [x] All 9 Kafka topics exist
  - [x] All 9 PostgreSQL tables exist with seed data
  - [x] All 3 Dapr components configured
  - [x] Master verification script passes

**Test Method**: 
```bash
cd infrastructure
time ./deploy-all.sh
./verify-all.sh
echo $?  # Should be 0
```

**Expected Duration**: 10-15 minutes

**Success Indicators**:
- Exit code 0 from both scripts
- No pods in CrashLoopBackOff
- All services have ClusterIP assigned

---

### TASK-029: Validate Against Success Criteria
- **Effort**: M (30 min)
- **Priority**: P0 - Blocker
- **Dependencies**: TASK-028
- **Owner**: Developer
- **Description**: Systematically verify all Part 1 success criteria from the specification.

**Acceptance Criteria**:
  - [x] ✅ Kafka deployed with all 9 topics created
  - [x] ✅ PostgreSQL deployed with complete schema
  - [x] ✅ Dapr installed with pub/sub and state components
  - [x] ✅ All services accessible within cluster
  - [x] ✅ Verification scripts passing
  - [x] ✅ Documentation complete
  - [x] ✅ No error pods or services
  - [x] ✅ Can produce/consume Kafka messages
  - [x] ✅ Can query PostgreSQL database
  - [x] ✅ Dapr components respond

**Test Method**: 
Execute all validation checks from Part 1 spec Section 10 (Success Metrics).

```bash
# Run all validation commands
kubectl get pods -A | grep -v "Running\|Completed"  # Should be empty
kubectl get svc -A
cd infrastructure
./verify-all.sh
```

**Documentation**:
Create a validation report documenting all checks and results.

---

### TASK-030: Create Validation and Test Report
- **Effort**: S (20 min)
- **Priority**: P1 - High
- **Dependencies**: TASK-029
- **Owner**: Developer
- **Description**: Document the complete validation process and results.

**Acceptance Criteria**:
  - [x] File `infrastructure/VALIDATION_REPORT.md` created
  - [x] Report includes timestamp of validation
  - [x] Report includes all verification script outputs
  - [x] Report documents any issues encountered
  - [x] Report documents resolutions applied
  - [x] Report confirms all success criteria met
  - [x] Screenshots or logs attached if applicable

**Test Method**: 
```bash
cat infrastructure/VALIDATION_REPORT.md
```

**Template**:
```markdown
# Infrastructure Validation Report

**Date**: YYYY-MM-DD HH:MM
**Validator**: [Name]
**Environment**: Minikube v1.x.x, Kubernetes v1.28.x

## Summary
✅ All infrastructure components successfully deployed and verified.

## Component Status
### Kafka
- Status: ✅ Operational
- Pods: 2/2 Running
- Topics: 9/9 Created
- Verification: PASS

### PostgreSQL
- Status: ✅ Operational
- Pods: 1/1 Running
- Tables: 9/9 Created
- Seed Data: Present
- Verification: PASS

### Dapr
- Status: ✅ Operational
- Control Plane: 3/3 Running
- Components: 3/3 Configured
- Verification: PASS

## Test Results
[Include output from verify-all.sh]

## Issues Encountered
None / [List any issues and resolutions]

## Next Steps
✅ Part 1 Complete - Ready for Part 2: Backend Services
```

---

## 📊 Task Summary

| Phase | Tasks | Total Effort | Priority |
|-------|-------|--------------|----------|
| Phase 1: Environment | 3 | XS (20 min) | P0-P1 |
| Phase 2: Kafka | 7 | M (165 min) | P1-P2 |
| Phase 3: PostgreSQL | 5 | M (145 min) | P1-P2 |
| Phase 4: Dapr | 6 | M (140 min) | P1-P2 |
| Phase 5: Master Scripts | 3 | L (95 min) | P0-P1 |
| Phase 6: Skills Updates | 3 | M (70 min) | P2 |
| Phase 7: Validation | 3 | L (110 min) | P0-P1 |
| **TOTAL** | **30** | **~12 hours** | **Mixed** |

---

## 🎯 Critical Path

The following tasks are on the critical path and must be completed in order:

1. TASK-001 → TASK-002 → TASK-004 → TASK-009 → TASK-010
2. TASK-011 → TASK-014 → TASK-015
3. TASK-016 → TASK-020 → TASK-021
4. TASK-022 → TASK-028 → TASK-029 → TASK-030

**Estimated Critical Path Duration**: 8-10 hours

---

## 🔄 Parallel Execution Opportunities

These tasks can be done in parallel to save time:

**Group A** (After TASK-001):
- TASK-004, TASK-005, TASK-006, TASK-007 (Kafka config files)
- TASK-011, TASK-012 (PostgreSQL config files)
- TASK-016, TASK-017, TASK-018 (Dapr config files)

**Group B** (After deployments):
- TASK-008, TASK-013, TASK-019, TASK-024 (Documentation)
- TASK-025, TASK-026, TASK-027 (Skills updates)

---

## ⚠️ Risk Mitigation

### Risk 1: Resource Constraints on Minikube
- **Impact**: Pods may fail to start due to insufficient CPU/memory
- **Mitigation**: Verify Minikube has 4 CPUs and 8GB RAM (TASK-002)
- **Rollback**: Increase Minikube resources and redeploy

### Risk 2: PersistentVolume Issues
- **Impact**: Kafka/PostgreSQL pods stuck in Pending
- **Mitigation**: Check storage class exists before deployment
- **Rollback**: Delete PVCs and redeploy

### Risk 3: Network/Helm Repository Access
- **Impact**: Unable to pull Helm charts or images
- **Mitigation**: Verify internet connectivity in TASK-002
- **Rollback**: Use cached images or local registry

---

## 📝 Notes

- All scripts should have proper error handling (`set -e`)
- All scripts should provide clear output with ✓/✗ indicators
- All YAML files should be validated with yamllint before committing
- Git commits should follow format: "Part 1: [Component] - [Action]"
- Test each component independently before running master scripts
- Keep terminal outputs for validation report

---

## 🚀 Quick Start for Developers

To execute all tasks in sequence:

```bash
# 1. Environment setup
cd learnflow-app
mkdir -p infrastructure/{kafka,postgres/init-scripts,dapr/components}

# 2. Create all configuration files
# (Follow TASK-004 through TASK-019)

# 3. Deploy everything
cd infrastructure
chmod +x *.sh kafka/*.sh postgres/*.sh dapr/*.sh
./deploy-all.sh

# 4. Verify everything
./verify-all.sh

# 5. Update skills library
# (Follow TASK-025 through TASK-027)

# 6. Create validation report
# (Follow TASK-030)
```

---

**End of Tasks Document**

This task breakdown provides a clear, actionable roadmap for implementing Part 1 of the LearnFlow infrastructure. Each task is well-defined with specific acceptance criteria and test methods.