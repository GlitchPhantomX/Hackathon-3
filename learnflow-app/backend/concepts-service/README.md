# concepts-service

AI-powered microservice for concepts operations using FastAPI and Dapr.

## Features
- FastAPI web framework
- Dapr integration for state management and pub/sub
- OpenAI SDK for agent logic
- Health and readiness checks
- Structured logging

## Endpoints
- `GET /health` - Health check
- `GET /ready` - Readiness check
- `POST /chat` - Main chat endpoint
- `GET /sessions/{user_id}` - User sessions

## Deployment
This service is designed to run with Dapr sidecar in Kubernetes.
