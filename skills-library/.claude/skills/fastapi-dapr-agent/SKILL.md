---
name: fastapi-dapr-agent
description: Generate FastAPI microservice with Dapr and OpenAI agent
---

# FastAPI Dapr Agent

## When to Use
Use this skill to create AI-powered microservices for triage, concepts, debug, and exercise agents.

## Instructions
1. Run `generate_service.py` to create FastAPI service structure
2. Run `deploy.sh` to build and deploy to Kubernetes

## Validation Checklist
- [ ] Service is running
- [ ] Dapr sidecar is healthy
- [ ] Agent responds to requests
- [ ] Kafka pub/sub working
- [ ] State management functional

For detailed patterns, see REFERENCE.md.