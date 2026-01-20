---
id: 4
title: backend-services-tasks
stage: tasks
date: 2026-01-20
surface: agent
model: claude-sonnet-4-5-20250929
feature: learnflow-backend-services
branch: 001-learnflow-backend-services
user: Claude
command: "/sp.tasks"
labels: ["tasks", "backend", "microservices", "learnflow", "implementation"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
 - specs/001-learnflow-backend-services/tasks.md
tests:
 - Tasks generated for all user stories
 - Task dependencies mapped
 - Parallel execution opportunities identified
 - Implementation strategy defined
 - MVP scope outlined
---
# Implementation Tasks: LearnFlow Backend Services

**Branch**: `001-learnflow-backend-services` | **Date**: 2026-01-20 | **Spec**: [link]

**Note**: This template is filled in by the `/sp.tasks` command. See `.specify/templates/commands/tasks.md` for the execution workflow.

## Summary

Generated comprehensive implementation tasks for the LearnFlow backend services, covering all 4 microservices (Triage, Concepts, Debug, Exercise) with a phased approach organized by user story priorities. Tasks are structured to enable parallel development after foundational setup, with clear dependencies and independent test criteria for each user story.

## Feature Overview
Implementation of 4 AI-powered microservices for the LearnFlow platform: Triage, Concepts, Debug, and Exercise services. The architecture utilizes FastAPI for service implementation, Dapr for service mesh capabilities, Apache Kafka for event streaming, and PostgreSQL for persistent storage.

## Implementation Strategy
- **MVP Approach**: Start with Triage Service (US1) as the core routing functionality
- **Incremental Delivery**: Each user story delivers independent value
- **Parallel Opportunities**: Services can be developed in parallel after foundational setup
- **Test-Driven**: Contract tests before implementation

## Dependencies
- User Story 1 (Triage) must be completed before other services can be fully tested
- Foundational setup (Docker, Dapr, Kafka, PostgreSQL) required before service development

## Parallel Execution Examples
- After foundational setup, services can be developed in parallel: [T050-T099], [T100-T149], [T150-T199], [T200-T249]
- Each service follows the same pattern: requirements.txt → main.py → Dockerfile → deployment.yaml

---

## Phase 1: Setup
Initialize project structure, dependencies, and foundational components for all services.

### Goal
Establish the foundational infrastructure and project structure needed for all backend services.

### Independent Test Criteria
- Docker environment is configured
- Dapr is initialized and running
- Project directory structure is created per plan
- Common dependencies are defined

### Tasks

- [ ] T001 Create learnflow-app directory structure per implementation plan
- [ ] T002 Initialize backend directory with subdirectories for each service
- [ ] T003 Create infrastructure/backend directory structure
- [ ] T004 Set up common configuration files (README.md, deploy-backend.sh, verify-backend.sh)
- [ ] T005 Create tests directory structure with integration and contract test directories

---

## Phase 2: Foundational Components
Establish shared infrastructure components needed by all services.

### Goal
Create shared components and dependencies that all services will use.

### Independent Test Criteria
- Common dependencies are properly defined
- Docker build environment is configured
- Dapr components are properly set up
- Kafka and PostgreSQL connections can be established

### Tasks

- [ ] T010 [P] Create common requirements.txt template for all services
- [ ] T011 [P] Set up Dapr pubsub Kafka component configuration
- [ ] T012 [P] Create backend config ConfigMap for services
- [ ] T013 [P] Create backend secrets template for services
- [ ] T014 [P] Set up Dockerfile template for Python services
- [ ] T015 [P] Create Kubernetes deployment template for services

---

## Phase 3: User Story 1 - Student Queries Routing (Priority: P1)

### Goal
Implement the Triage Service that routes student queries to appropriate specialist services (Concepts, Debug, or Exercise).

### Independent Test Criteria
Can be fully tested by submitting various types of queries (conceptual, debugging, exercise-related) and verifying they reach the correct specialist service, delivering accurate responses to students.

### Acceptance Scenarios
1. Given a student submits a query about Python concepts, When the query is processed by the Triage Service, Then it is routed to the Concepts Service and a conceptual explanation is returned
2. Given a student submits a query with error messages or code problems, When the query is processed by the Triage Service, Then it is routed to the Debug Service and debugging assistance is returned
3. Given a student requests practice exercises or challenges, When the query is processed by the Triage Service, Then it is routed to the Exercise Service and practice materials are returned

### Tasks

#### Triage Service Implementation

- [ ] T050 [US1] Create triage-service directory structure
- [ ] T051 [US1] Create triage-service requirements.txt with FastAPI, Dapr, Pydantic dependencies
- [ ] T052 [US1] Implement main.py with FastAPI app and health check endpoint
- [ ] T053 [US1] Implement StudentQuery and TriageResponse Pydantic models
- [ ] T054 [US1] Implement determine_route function with keyword matching logic
- [ ] T055 [US1] Implement triage_query endpoint with routing logic
- [ ] T056 [US1] Implement routing to appropriate Kafka topics (learning.query.concepts, debug, exercise)
- [ ] T057 [US1] Implement acknowledgment publishing to learning.response topic
- [ ] T058 [US1] Add proper logging and error handling
- [ ] T059 [US1] Implement stats endpoint with routing rules

#### Triage Service Infrastructure

- [ ] T060 [US1] Create triage-service Dockerfile based on template
- [ ] T061 [US1] Create triage-service deployment.yaml with Dapr annotations
- [ ] T062 [US1] Add proper resource limits and health checks to deployment
- [ ] T063 [US1] Create triage-service README.md with usage instructions

#### Triage Service Testing

- [ ] T064 [US1] Create contract test for triage service API endpoints
- [ ] T065 [US1] Create integration test for routing logic
- [ ] T066 [US1] Create test for Kafka message publishing

---

## Phase 4: User Story 2 - Concept Explanation Service (Priority: P1)

### Goal
Implement the Concepts Service that explains Python programming concepts with beginner-friendly explanations and practical code examples.

### Independent Test Criteria
Can be fully tested by submitting concept-related queries and verifying the system returns clear explanations with code examples, key takeaways, and follow-up questions.

### Acceptance Scenarios
1. Given a student asks about Python loops, When the Concepts Service processes the query, Then it returns a clear explanation with code examples and practice questions

### Tasks

#### Concepts Service Implementation

- [ ] T100 [US2] Create concepts-service directory structure
- [ ] T101 [US2] Create concepts-service requirements.txt with FastAPI, Dapr, OpenAI, Pydantic dependencies
- [ ] T102 [US2] Implement main.py with FastAPI app and health check endpoint
- [ ] T103 [US2] Implement ConceptQuery Pydantic model
- [ ] T104 [US2] Implement OpenAI client configuration with API key from environment
- [ ] T105 [US2] Implement SYSTEM_PROMPT with educational tutoring instructions
- [ ] T106 [US2] Implement explain_concept function with OpenAI API call
- [ ] T107 [US2] Implement extract_topic function for concept identification
- [ ] T108 [US2] Implement Dapr subscription for learning.query.concepts topic
- [ ] T109 [US2] Implement response publishing to learning.response topic
- [ ] T110 [US2] Add proper logging and error handling

#### Concepts Service Infrastructure

- [ ] T111 [US2] Create concepts-service Dockerfile based on template
- [ ] T112 [US2] Create concepts-service deployment.yaml with Dapr annotations and OpenAI secret mount
- [ ] T113 [US2] Add proper resource limits and health checks to deployment
- [ ] T114 [US2] Create concepts-service README.md with usage instructions

#### Concepts Service Testing

- [ ] T115 [US2] Create contract test for concepts service API endpoints
- [ ] T116 [US2] Create integration test for OpenAI API interaction
- [ ] T117 [US2] Create test for Dapr subscription and response publishing

---

## Phase 5: User Story 3 - Debug Assistance Service (Priority: P1)

### Goal
Implement the Debug Service that provides detailed debugging help including error analysis, explanation of why the error occurred, corrected code, and debugging tips.

### Independent Test Criteria
Can be fully tested by submitting code with various error types and verifying the system returns proper error analysis and solutions.

### Acceptance Scenarios
1. Given a student submits code with a syntax error, When the Debug Service processes it, Then it returns error analysis, explanation, corrected code, and debugging tips

### Tasks

#### Debug Service Implementation

- [ ] T150 [US3] Create debug-service directory structure
- [ ] T151 [US3] Create debug-service requirements.txt with FastAPI, Dapr, OpenAI, Pydantic dependencies
- [ ] T152 [US3] Implement main.py with FastAPI app and health check endpoint
- [ ] T153 [US3] Implement DebugQuery Pydantic model
- [ ] T154 [US3] Implement OpenAI client configuration with API key from environment
- [ ] T155 [US3] Implement SYSTEM_PROMPT with debugging assistant instructions
- [ ] T156 [US3] Implement debug_code function with OpenAI API call
- [ ] T157 [US3] Implement extract_error_type function for error classification
- [ ] T158 [US3] Implement Dapr subscription for learning.query.debug topic
- [ ] T159 [US3] Implement response publishing to learning.response topic
- [ ] T160 [US3] Add proper logging and error handling

#### Debug Service Infrastructure

- [ ] T161 [US3] Create debug-service Dockerfile based on template
- [ ] T162 [US3] Create debug-service deployment.yaml with Dapr annotations and OpenAI secret mount
- [ ] T163 [US3] Add proper resource limits and health checks to deployment
- [ ] T164 [US3] Create debug-service README.md with usage instructions

#### Debug Service Testing

- [ ] T165 [US3] Create contract test for debug service API endpoints
- [ ] T166 [US3] Create integration test for OpenAI API interaction
- [ ] T167 [US3] Create test for Dapr subscription and response publishing

---

## Phase 6: User Story 4 - Exercise Generation and Grading (Priority: P2)

### Goal
Implement the Exercise Service that generates appropriate coding exercises and evaluates student solutions with feedback.

### Independent Test Criteria
Can be fully tested by requesting exercises and verifying they are generated appropriately, then submitting solutions and verifying grading accuracy.

### Acceptance Scenarios
1. Given a student requests Python exercises, When the Exercise Service processes the request, Then it generates appropriate coding challenges and can grade submitted solutions

### Tasks

#### Exercise Service Implementation

- [ ] T200 [US4] Create exercise-service directory structure
- [ ] T201 [US4] Create exercise-service requirements.txt with FastAPI, Dapr, OpenAI, Pydantic dependencies
- [ ] T202 [US4] Implement main.py with FastAPI app and health check endpoint
- [ ] T203 [US4] Implement ExerciseQuery Pydantic model
- [ ] T204 [US4] Implement OpenAI client configuration with API key from environment
- [ ] T205 [US4] Implement SYSTEM_PROMPT with exercise generation instructions
- [ ] T206 [US4] Implement generate_exercise function with OpenAI API call
- [ ] T207 [US4] Implement grade_solution function for evaluating submissions
- [ ] T208 [US4] Implement Dapr subscription for learning.query.exercise topic
- [ ] T209 [US4] Implement response publishing to learning.response topic
- [ ] T210 [US4] Add proper logging and error handling

#### Exercise Service Infrastructure

- [ ] T211 [US4] Create exercise-service Dockerfile based on template
- [ ] T212 [US4] Create exercise-service deployment.yaml with Dapr annotations and OpenAI secret mount
- [ ] T213 [US4] Add proper resource limits and health checks to deployment
- [ ] T214 [US4] Create exercise-service README.md with usage instructions

#### Exercise Service Testing

- [ ] T215 [US4] Create contract test for exercise service API endpoints
- [ ] T220 [US4] Create integration test for OpenAI API interaction
- [ ] T221 [US4] Create test for Dapr subscription and response publishing

---

## Phase 7: Polish & Cross-Cutting Concerns

### Goal
Complete the implementation with security, monitoring, documentation, and deployment validation.

### Independent Test Criteria
All services are properly secured, monitored, documented, and can be deployed successfully to Kubernetes.

### Tasks

#### Security & Authentication

- [ ] T300 Implement authentication middleware based on FR-012 requirements
- [ ] T301 Add proper secret management for OpenAI API keys
- [ ] T302 Implement encryption for sensitive data based on FR-010

#### Monitoring & Observability

- [ ] T303 Add structured logging to all services
- [ ] T304 Add metrics endpoints to all services
- [ ] T305 Implement distributed tracing with Dapr

#### Data Persistence

- [ ] T306 Implement PostgreSQL integration for interaction history (FR-013)
- [ ] T307 Create database schema for storing student queries and responses
- [ ] T308 Add Dapr state store configuration for session context

#### Edge Case Handling

- [ ] T309 Implement graceful handling of AI API unavailability (edge case #1)
- [ ] T310 Add input validation for long/malformed queries (edge case #2)
- [ ] T311 Implement rate limiting and concurrency handling (edge case #3)
- [ ] T312 Add fallback routing for ambiguous queries (edge case #4)

#### Integration & Validation

- [ ] T313 Create end-to-end integration tests for the full query routing flow
- [ ] T314 Validate all services against success criteria (SC-001 through SC-010)
- [ ] T315 Performance test to validate 1000 concurrent users support (SC-009)
- [ ] T316 Security validation for educational privacy compliance (SC-010)

#### Documentation & Deployment

- [ ] T317 Update README.md with complete setup and deployment instructions
- [ ] T318 Create deployment validation script (verify-backend.sh)
- [ ] T319 Update API documentation based on implemented contracts
- [ ] T320 Final integration testing of all services together

## Outcome

- ✅ Impact: Complete task breakdown for LearnFlow backend services implementation
- 🧪 Tests: All user stories mapped to specific, testable tasks
- 📁 Files: tasks.md created with comprehensive task list
- 🔁 Next prompts: Ready for implementation with `/sp.implement`
- 🧠 Reflection: Tasks organized by user story with clear dependencies and parallel execution opportunities

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): PASS - All tasks properly formatted and linked to requirements
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Begin implementation with Phase 1 tasks