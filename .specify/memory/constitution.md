<!--
Sync Impact Report:
Version change: 1.0.0 → 1.0.0 (full replacement)
Added sections: Complete Hackathon III constitution content
Removed sections: Previous constitution content
Templates requiring updates: N/A (complete replacement)
Modified principles: All principles replaced with comprehensive Hackathon III guide
-->
# Hackathon III: Reusable Intelligence and Cloud-Native Mastery
## Complete Project Constitution & Implementation Guide

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Core Principles & Philosophy](#core-principles--philosophy)
3. [Technology Stack Architecture](#technology-stack-architecture)
4. [Development Methodology](#development-methodology)
5. [Deliverables Structure](#deliverables-structure)
6. [Implementation Phases](#implementation-phases)
7. [Skills Development Framework](#skills-development-framework)
8. [LearnFlow Application Specifications](#learnflow-application-specifications)
9. [Evaluation Criteria & Standards](#evaluation-criteria--standards)
10. [Quality Assurance Guidelines](#quality-assurance-guidelines)

---

## 1. Executive Summary

### 1.1 Project Vision
Hackathon III represents a paradigm shift from traditional software development to **Agentic AI-Driven Development**. The project focuses on teaching AI coding agents (Claude Code and Goose) to autonomously build sophisticated cloud-native applications through reusable, token-efficient Skills.

### 1.2 Key Objectives
- Implement MCP Code Execution pattern for 80-98% token reduction
- Create 7+ reusable Skills working across Claude Code, Goose, and OpenAI Codex
- Build LearnFlow: An AI-powered Python tutoring platform
- Deploy on Kubernetes with event-driven microservices architecture
- Achieve maximum AI autonomy (single-prompt-to-deployment)

### 1.3 Success Metrics
- **Skills Autonomy**: AI deploys from single prompt with zero manual intervention
- **Token Efficiency**: Scripts execute outside context window
- **Cross-Compatibility**: Skills work on multiple AI agents
- **Application Completion**: Full LearnFlow platform operational
- **Documentation Quality**: Comprehensive auto-generated documentation

---

## 2. Core Principles & Philosophy

### 2.1 From Coder to Teacher Paradigm

**Traditional Development:**
```
Developer → Writes Code → Code Runs → Application Works
```

**Agentic Development:**
```
Developer → Writes Skills → AI Learns → AI Writes Code → Application Works
```

**Key Difference**: Skills are reusable across infinite applications, not single-use code.

### 2.2 The Skills Are The Product

**Critical Understanding:**
- Skills are the PRIMARY deliverable
- LearnFlow app is the DEMONSTRATION vehicle
- Judges evaluate BOTH the Skills AND the development process
- Goal: Skills that work autonomously = Winners queue entry

### 2.3 MCP Code Execution Philosophy

**Problem**: Direct MCP integration consumes 25-50% context window before conversation starts

**Solution**: Wrap MCP in executable scripts
- SKILL.md: ~100 tokens (instructions only)
- scripts/: 0 tokens (executed, never loaded)
- Output: Minimal result only

**Result**: 80-98% token reduction with full capability maintained

---

## 3. Technology Stack Architecture

### 3.1 Core Technologies Matrix

| Layer | Technology | Purpose | Integration Point |
|-------|-----------|---------|-------------------|
| **AI Agents** | Claude Code, Goose | Execute Skills autonomously | Primary orchestration |
| **Frontend** | Next.js 14 + Monaco Editor | User interface with code execution | Student/Teacher dashboards |
| **Backend** | FastAPI + OpenAI SDK | AI-powered microservices | Agent services layer |
| **Authentication** | Better Auth | User management | Role-based access control |
| **Service Mesh** | Dapr | State, pub/sub, invocation | Microservices communication |
| **Event Streaming** | Apache Kafka | Async event-driven architecture | Inter-service messaging |
| **Database** | PostgreSQL (Neon) | Persistent data storage | User data, progress tracking |
| **Orchestration** | Kubernetes (Minikube) | Container management | All services deployment |
| **Package Manager** | Helm 3 | K8s application deployment | Infrastructure provisioning |
| **AI Context** | MCP Servers | Real-time data access for AI | Contextual intelligence |
| **Documentation** | Docusaurus | Auto-generated docs site | Project documentation |
| **GitOps CD** | Argo CD + GitHub Actions | Continuous delivery | Automated deployments |
| **Spec Framework** | Spec-Kit Plus (15%) | Spec-driven development | High-level specifications |

### 3.2 LearnFlow Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                            │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │  │
│  │  │   Next.js    │  │   FastAPI    │  │   FastAPI    │   │  │
│  │  │   Frontend   │  │Triage Service│  │Concepts Svc  │   │  │
│  │  │+Monaco Editor│  │  +Dapr       │  │  +Dapr       │   │  │
│  │  │   (Port 3000)│  │+OpenAI Agent │  │+OpenAI Agent │   │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘   │  │
│  │         │                  │                  │            │  │
│  │         └──────────────────┴──────────────────┘            │  │
│  │                            │                                │  │
│  │                            ▼                                │  │
│  │         ┌─────────────────────────────────────┐            │  │
│  │         │         APACHE KAFKA                 │            │  │
│  │         │  Topics: learning.*, code.*,        │            │  │
│  │         │  exercise.*, struggle.alerts        │            │  │
│  │         └──────────────┬──────────────────────┘            │  │
│  │                        │                                    │  │
│  │         ┌──────────────┴──────────────┐                    │  │
│  │         ▼                              ▼                    │  │
│  │  ┌─────────────┐              ┌──────────────┐            │  │
│  │  │ PostgreSQL  │              │ MCP Server   │            │  │
│  │  │  (Neon DB)  │              │  (Context)   │            │  │
│  │  └─────────────┘              └──────────────┘            │  │
│  │                                                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Microservices Communication Flow

```
Student Request → Next.js Frontend
                     ↓
                 Triage Service (FastAPI + Dapr)
                     ↓
            ┌────────┴────────┐
            ▼                 ▼
    Concepts Service    Debug Service
    (OpenAI Agent)      (OpenAI Agent)
            │                 │
            └────────┬────────┘
                     ▼
              Kafka Topics
         (learning.events, code.*)
                     ↓
              PostgreSQL DB
         (Progress, Submissions)
```

---

## 4. Development Methodology

### 4.1 Agentic Development Workflow

**Phase Structure:**
1. Write Skill specifications (SKILL.md + scripts/)
2. AI Agent reads Skill
3. AI Agent executes scripts
4. AI Agent builds application components
5. Verify and iterate

**Key Principle**: Never write application code manually. Always use Skills + AI Agents.

### 4.2 Skill Development Pattern

**Directory Structure Template:**
```
.claude/skills/<skill-name>/
├── SKILL.md           # ~100 tokens: What to do
├── REFERENCE.md       # 0 tokens initially: Deep documentation
└── scripts/           # 0 tokens: Executable logic
    ├── deploy.sh      # Deployment automation
    ├── verify.py      # Validation checks
    └── templates/     # Code/config templates
```

**SKILL.md Template:**
```yaml
---
name: skill-name
description: Brief description of capability
---

# Skill Title

## When to Use
- Trigger condition 1
- Trigger condition 2

## Instructions
1. Step 1: `command or script`
2. Step 2: `command or script`
3. Validation step

## Validation Checklist
- [ ] Success criterion 1
- [ ] Success criterion 2

See [REFERENCE.md](./REFERENCE.md) for advanced configuration.
```

### 4.3 Token Optimization Strategy

| Component | Token Cost | Strategy |
|-----------|-----------|----------|
| SKILL.md | ~100 | Minimal instructions only |
| REFERENCE.md | 0 (on-demand) | Loaded only when needed |
| scripts/*.sh | 0 | Executed, never loaded |
| scripts/*.py | 0 | Executed, never loaded |
| Final output | ~10-50 | Minimal result string |

**Before (Direct MCP)**: 50,000+ tokens
**After (Skills + Scripts)**: ~110 tokens (99% reduction)

---

## 5. Deliverables Structure

### 5.1 Repository 1: skills-library

**Purpose**: Reusable AI Skills working across Claude Code, Goose, and OpenAI Codex

**Structure:**
```
skills-library/
├── README.md                          # Project overview
├── .gitignore                         # Git exclusions
├── .claude/
│   └── skills/
│       ├── agents-md-gen/             # AGENTS.md generator
│       │   ├── SKILL.md
│       │   ├── REFERENCE.md
│       │   └── scripts/
│       │       └── generate_agents_md.py
│       ├── kafka-k8s-setup/           # Kafka deployment
│       │   ├── SKILL.md
│       │   ├── REFERENCE.md
│       │   └── scripts/
│       │       ├── deploy.sh
│       │       ├── verify.py
│       │       └── create_topics.sh
│       ├── postgres-k8s-setup/        # PostgreSQL deployment
│       │   ├── SKILL.md
│       │   ├── REFERENCE.md
│       │   └── scripts/
│       │       ├── deploy.sh
│       │       ├── verify.py
│       │       ├── init_schema.sql
│       │       └── migrate.py
│       ├── fastapi-dapr-agent/        # Microservice generator
│       │   ├── SKILL.md
│       │   ├── REFERENCE.md
│       │   └── scripts/
│       │       ├── generate_service.py
│       │       ├── deploy.sh
│       │       └── templates/
│       │           ├── main.py.template
│       │           ├── Dockerfile.template
│       │           ├── deployment.yaml.template
│       │           └── requirements.txt.template
│       ├── mcp-code-execution/        # MCP wrapper pattern
│       │   ├── SKILL.md
│       │   ├── REFERENCE.md
│       │   └── scripts/
│       │       ├── wrap_mcp_server.py
│       │       ├── mcp_client_template.py
│       │       └── examples/
│       │           ├── gdrive_example.py
│       │           ├── k8s_example.py
│       │           └── slack_example.py
│       ├── nextjs-k8s-deploy/         # Frontend deployment
│       │   ├── SKILL.md
│       │   ├── REFERENCE.md
│       │   └── scripts/
│       │       ├── generate_nextjs_app.sh
│       │       ├── add_monaco.sh
│       │       ├── dockerize.sh
│       │       ├── deploy.sh
│       │       └── templates/
│       │           ├── Dockerfile.template
│       │           └── deployment.yaml.template
│       └── docusaurus-deploy/         # Documentation site
│           ├── SKILL.md
│           ├── REFERENCE.md
│           └── scripts/
│               ├── init_docs.sh
│               ├── generate_api_docs.py
│               ├── build_deploy.sh
│               └── templates/
│                   ├── docusaurus.config.js.template
│                   └── deployment.yaml.template
└── docs/
    └── skill-development-guide.md     # Skill creation guide
```

### 5.2 Repository 2: learnflow-app

**Purpose**: Complete AI-powered Python tutoring platform built using Skills

**Structure:**
```
learnflow-app/
├── README.md                          # Application overview
├── .gitignore                         # Git exclusions
├── AGENTS.md                          # AI agent guidelines
├── .claude/
│   └── skills/                        # Symlink to skills-library
├── frontend/                          # Next.js application
│   ├── package.json
│   ├── next.config.js
│   ├── tsconfig.json
│   ├── tailwind.config.js
│   ├── src/
│   │   ├── app/
│   │   │   ├── page.tsx              # Landing page
│   │   │   ├── student/              # Student dashboard
│   │   │   └── teacher/              # Teacher dashboard
│   │   ├── components/
│   │   │   ├── CodeEditor.tsx        # Monaco integration
│   │   │   ├── ChatInterface.tsx     # AI chat UI
│   │   │   └── ProgressTracker.tsx   # Mastery display
│   │   └── lib/
│   │       └── api.ts                # Backend API calls
│   ├── Dockerfile
│   └── kubernetes/
│       └── deployment.yaml
├── backend/                           # FastAPI microservices
│   ├── triage-service/
│   │   ├── main.py                   # FastAPI app + Dapr
│   │   ├── agent.py                  # OpenAI agent logic
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── kubernetes/
│   │       └── deployment.yaml       # K8s + Dapr sidecar
│   ├── concepts-service/
│   │   ├── main.py
│   │   ├── agent.py                  # Concepts explainer
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── kubernetes/
│   │       └── deployment.yaml
│   ├── debug-service/
│   │   ├── main.py
│   │   ├── agent.py                  # Error analyzer
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── kubernetes/
│   │       └── deployment.yaml
│   └── exercise-service/
│       ├── main.py
│       ├── agent.py                  # Challenge generator
│       ├── requirements.txt
│       ├── Dockerfile
│       └── kubernetes/
│           └── deployment.yaml
├── infrastructure/                    # K8s infrastructure
│   ├── kubernetes/
│   │   ├── namespace.yaml
│   │   ├── configmaps/
│   │   └── secrets/
│   ├── helm/
│   │   ├── kafka/                    # Kafka Helm values
│   │   └── postgresql/               # PostgreSQL Helm values
│   └── dapr/
│       ├── components/
│       │   ├── pubsub.yaml          # Kafka pub/sub
│       │   └── statestore.yaml      # State management
│       └── configuration/
├── mcp-servers/                       # MCP context providers
│   ├── context-server/
│   │   ├── server.py                 # MCP server implementation
│   │   ├── requirements.txt
│   │   └── config.json
│   └── README.md
└── docs/                              # Docusaurus documentation
    ├── docs/
    │   ├── architecture.md
    │   ├── api/
    │   │   ├── triage.md
    │   │   ├── concepts.md
    │   │   ├── debug.md
    │   │   └── exercise.md
    │   └── deployment.md
    ├── docusaurus.config.js
    └── package.json
```

---

## 6. Implementation Phases

### Phase 1: Environment Setup (Day 1)

**Objectives:**
- Install all prerequisites
- Initialize repositories
- Verify tooling

**Prerequisites Installation (WSL on Windows):**

```bash
# 1. Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop/

# 2. WSL2 Setup
wsl --install
wsl --set-default-version 2

# 3. Inside WSL Terminal:

# Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Claude Code
curl -fsSL https://claude.ai/install.sh | bash
claude auth login

# Goose
curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash

# 4. Start Minikube
minikube start --cpus=4 --memory=8192 --driver=docker

# 5. Verify
docker --version
minikube status
kubectl cluster-info
helm version
claude --version
goose --version
```

**Repository Initialization:**
```bash
# Create project structure
mkdir hackathon-3 && cd hackathon-3

# Initialize repositories
mkdir skills-library learnflow-app

cd skills-library
git init
mkdir -p .claude/skills docs

cd ../learnflow-app
git init
mkdir -p .claude/skills frontend backend infrastructure mcp-servers docs
```

**Success Criteria:**
- ✅ All tools installed and verified
- ✅ Minikube cluster running
- ✅ Both repositories initialized
- ✅ kubectl can connect to cluster

---

### Phase 2: Foundation Skills (Day 1-2)

**Skill 1: agents-md-gen**

**Purpose**: Generate comprehensive AGENTS.md files for repositories

**Implementation:**
```bash
cd skills-library/.claude/skills
mkdir -p agents-md-gen/scripts
```

**SKILL.md Content:**
```yaml
---
name: agents-md-gen
description: Generate comprehensive AGENTS.md documentation for AI agents
---

# Agents Markdown Generator

## When to Use
- Initializing new repositories
- AI agents need repository context
- Updating project documentation

## Instructions
1. Analyze repository structure: `python scripts/generate_agents_md.py --analyze`
2. Generate AGENTS.md: `python scripts/generate_agents_md.py --generate`
3. Verify output: Check AGENTS.md created in repository root

## Validation
- [ ] AGENTS.md exists in repository root
- [ ] Contains architecture overview
- [ ] Includes file structure
- [ ] Lists conventions and guidelines

See [REFERENCE.md](./REFERENCE.md) for customization options.
```

**Script: scripts/generate_agents_md.py**
```python
#!/usr/bin/env python3
import os
import sys
import argparse
from pathlib import Path

def analyze_repository(repo_path):
    """Analyze repository structure"""
    structure = []
    for root, dirs, files in os.walk(repo_path):
        level = root.replace(repo_path, '').count(os.sep)
        indent = ' ' * 2 * level
        structure.append(f"{indent}{os.path.basename(root)}/")
        subindent = ' ' * 2 * (level + 1)
        for file in files[:5]:  # Limit to first 5 files per directory
            structure.append(f"{subindent}{file}")
    return "\n".join(structure)

def generate_agents_md(repo_path, structure):
    """Generate AGENTS.md content"""
    content = f"""# AGENTS.md

## Repository Overview
This repository is part of Hackathon III: LearnFlow Application.

## Architecture
[Architecture diagram and description]

## Repository Structure
```
{structure}
```

## Conventions
- Follow MCP Code Execution pattern
- Use Skills for all AI agent interactions
- Commit messages: "Agent: action using skill-name"

## Guidelines for AI Agents
1. Read this file before making changes
2. Use existing Skills from .claude/skills/
3. Follow the established architecture patterns
4. Test locally before committing

## Key Technologies
- Kubernetes + Minikube
- FastAPI + Dapr
- Apache Kafka
- PostgreSQL
- Next.js + Monaco Editor
"""

    agents_md_path = os.path.join(repo_path, 'AGENTS.md')
    with open(agents_md_path, 'w') as f:
        f.write(content)

    return agents_md_path

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--analyze', action='store_true')
    parser.add_argument('--generate', action='store_true')
    parser.add_argument('--path', default='.', help='Repository path')
    args = parser.parse_args()

    if args.analyze or args.generate:
        structure = analyze_repository(args.path)
        if args.analyze:
            print(structure)
        if args.generate:
            path = generate_agents_md(args.path, structure)
            print(f"✓ AGENTS.md created at {path}")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
```

**Success Criteria:**
- ✅ Skill generates valid AGENTS.md from single prompt
- ✅ Works on both Claude Code and Goose
- ✅ Output is comprehensive and accurate

---

### Phase 3: Infrastructure Skills (Day 2-3)

**Skill 2: kafka-k8s-setup**

**Skill 3: postgres-k8s-setup**

*[Full implementation details in SKILL.md templates above]*

**Kafka Topics for LearnFlow:**
- `learning.events` - Student learning activities
- `code.executions` - Code run requests/results
- `exercise.submissions` - Exercise completions
- `struggle.alerts` - Student difficulty signals

**PostgreSQL Schema for LearnFlow:**
```sql
-- users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('student', 'teacher')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- student_progress table
CREATE TABLE student_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    module INTEGER NOT NULL CHECK (module BETWEEN 1 AND 8),
    mastery_score DECIMAL(5,2) DEFAULT 0.00,
    streak INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- exercises table
CREATE TABLE exercises (
    id SERIAL PRIMARY KEY,
    topic VARCHAR(255) NOT NULL,
    difficulty VARCHAR(50) CHECK (difficulty IN ('easy', 'medium', 'hard')),
    question TEXT NOT NULL,
    solution TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- code_submissions table
CREATE TABLE code_submissions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    exercise_id INTEGER REFERENCES exercises(id),
    code TEXT NOT NULL,
    status VARCHAR(50) CHECK (status IN ('pending', 'passed', 'failed')),
    feedback TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Success Criteria:**
- ✅ AI agents autonomously deploy Kafka
- ✅ AI agents autonomously deploy PostgreSQL
- ✅ All topics created and verified
- ✅ Database schema initialized

---

### Phase 4: Backend Services (Day 3-4)

**Skill 4: fastapi-dapr-agent**

**Purpose**: Generate FastAPI microservices with Dapr sidecars and OpenAI agents

**Agent Services to Create:**

**1. Triage Service (Port 8001)**
```python
# main.py template structure
from fastapi import FastAPI
from dapr.clients import DaprClient
from openai import OpenAI

app = FastAPI()
client = OpenAI()

@app.post("/chat")
async def route_query(message: str):
    """Route to appropriate agent"""
    # Analyze intent
    if "explain" in message.lower():
        return {"route": "concepts", "message": message}
    elif "error" in message.lower():
        return {"route": "debug", "message": message}
    elif "exercise" in message.lower():
        return {"route": "exercise", "message": message}

    # Publish to Kafka via Dapr
    with DaprClient() as d:
        d.publish_event(
            pubsub_name='kafka-pubsub',
            topic_name='learning.events',
            data=message
        )
```

**2. Concepts Service (Port 8002)**
- Explains Python concepts with examples
- OpenAI agent with teaching system prompt
- Subscribes to `learning.events` topic

**3. Debug Service (Port 8003)**
- Parses errors and identifies root causes
- Provides hints before full solutions
- Publishes to `struggle.alerts` when student stuck

**4. Exercise Service (Port 8004)**
- Generates coding challenges
- Auto-grades submissions
- Publishes results to `exercise.submissions`

**Dapr Configuration Template:**
```yaml
# components/pubsub.yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: kafka-pubsub
spec:
  type: pubsub.kafka
  version: v1
  metadata:
  - name: brokers
    value: "kafka:9092"
  - name: consumerGroup
    value: "learnflow-group"
```

**Success Criteria:**
- ✅ All 4 services generated and deployed
- ✅ Dapr sidecars configured correctly
- ✅ Kafka pub/sub working
- ✅ OpenAI agents responding appropriately

---

### Phase 5: Frontend Development (Day 4-5)

**Skill 5: nextjs-k8s-deploy**

**Next.js Pages Structure:**

**Student Dashboard (`/student`):**
- Module progress cards (8 Python modules)
- Mastery score visualization with color coding
- Streak tracker
- Chat interface with AI tutor
- Monaco code editor
- Quiz interface

**Teacher Dashboard (`/teacher`):**
- Class progress overview
- Struggle alerts list
- Exercise generator interface
- Student monitoring panel

**Monaco Editor Integration:**
```tsx
// components/CodeEditor.tsx
import Editor from '@monaco-editor/react';

export function CodeEditor({ onRun }) {
  const [code, setCode] = useState('');

  return (
    <div>
      <Editor
        height="400px"
        defaultLanguage="python"
        value={code}
        onChange={setCode}
        theme="vs-dark"
      />
      <button onClick={() => onRun(code)}>
        Run Code
      </button>
    </div>
  );
}
```

**Success Criteria:**
- ✅ Frontend deployed to Kubernetes
- ✅ Monaco editor functional
- ✅ API integration with backend services
- ✅ Authentication working (Better Auth)
- ✅ Real-time updates via WebSocket

---

### Phase 6: Integration & Documentation (Day 5-6)

**Skill 6: mcp-code-execution**

**Purpose**: Wrap MCP servers in code execution pattern

**Example MCP Wrapper:**
```python
# scripts/examples/k8s_example.py
import subprocess
import json

def get_pod_status(namespace="default"):
    """Get pod status via kubectl (wrapped MCP call)"""
    result = subprocess.run(
        ["kubectl", "get", "pods", "-n", namespace, "-o", "json"],
        capture_output=True,
        text=True
    )

    pods = json.loads(result.stdout)["items"]
    running = [p for p in pods if p["status"]["phase"] == "Running"]

    # Only return minimal result
    return f"✓ {len(running)}/{len(pods)} pods running in {namespace}"

# Usage: AI agent calls this function, gets minimal output
print(get_pod_status("kafka"))
```

**Skill 7: docusaurus-deploy**

**Auto-Generated Documentation Structure:**
```
docs/
├── docs/
│   ├── intro.md                    # Project overview
│   ├── architecture.md             # System architecture
│   ├── getting-started.md          # Setup guide
│   ├── api/
│   │   ├── triage-service.md       # Auto-generated from OpenAPI
│   │   ├── concepts-service.md
│   │   ├── debug-service.md
│   │   └── exercise-service.md
│   ├── skills/
│   │   ├── overview.md
│   │   └── [skill-name].md         # Auto-generated for each skill
│   └── deployment/
│       ├── kubernetes.md
│       ├── kafka.md
│       └── postgresql.md
└── docusaurus.config.js
```

**Success Criteria:**
- ✅ MCP server provides rich context
- ✅ Documentation site auto-generated
- ✅ Documentation deployed to Kubernetes
- ✅ Search functionality working

---

### Phase 7: LearnFlow Complete Build (Day 6-7)

**Using AI Agents to Build Application:**

**Example Prompts for Claude Code:**

```bash
# 1. Deploy infrastructure
claude "Use kafka-k8s-setup skill to deploy Kafka with topics: learning.events, code.executions, exercise.submissions, struggle.alerts"

# 2. Deploy database
claude "Use postgres-k8s-setup skill to deploy PostgreSQL and initialize LearnFlow schema"

# 3. Create services
claude "Use fastapi-dapr-agent skill to generate triage-service on port 8001 with OpenAI routing logic"

claude "Use fastapi-dapr-agent skill to generate concepts-service on port 8002 with Python teaching agent"

# 4. Deploy frontend
claude "Use nextjs-k8s-deploy skill to create LearnFlow frontend with student and teacher dashboards, Monaco editor integration"

# 5. Generate documentation
claude "Use docusaurus-deploy skill to auto-generate complete documentation site for LearnFlow"
```

**Demo Scenario Implementation:**

**Test Flow:**
1. Student Maya logs in → Dashboard shows "Module 2: Loops - 60% complete"
2. Maya asks: "How do for loops work in Python?"
3. Triage Service routes to Concepts Agent
4. Concepts Agent explains with examples
5. Concepts Agent provides practice exercise
