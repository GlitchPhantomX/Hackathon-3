# FastAPI Dapr Agent - Detailed Documentation

## Overview
The FastAPI Dapr Agent skill generates production-ready AI-powered microservices using FastAPI, Dapr (Distributed Application Runtime), and OpenAI SDK. It supports various agent types including triage, concepts, debug, and exercise agents for the LearnFlow application.

## Architecture
- FastAPI as the web framework with async support
- Dapr sidecar for state management, pub/sub, and service discovery
- OpenAI SDK for AI agent logic
- Kafka for event streaming
- PostgreSQL for persistent state

## Dapr Patterns
- **State Management**: Store and retrieve agent state using Dapr state store
- **Service Invocation**: Call other services using Dapr service-to-service communication
- **Pub/Sub**: Publish events to Kafka topics for asynchronous processing
- **Bindings**: Connect to external systems using Dapr bindings
- **Secrets Management**: Secure access to API keys and credentials

## OpenAI SDK Integration
- Chat Completions API for conversational agents
- Function calling for tool integration
- Streaming responses for real-time interaction
- Token management and rate limiting

## Agent Types
### Triage Service
- Routes incoming queries to appropriate agents
- Determines query complexity and priority
- Orchestrates multi-step workflows

### Concepts Service
- Explains programming concepts in simple terms
- Provides examples and analogies
- Tracks learning progress

### Debug Service
- Analyzes code errors and provides fixes
- Suggests improvements and best practices
- Maintains context of debugging sessions

### Exercise Service
- Generates personalized coding challenges
- Evaluates code submissions
- Provides adaptive learning paths

## Template Structure
Generated services include:
- `main.py`: FastAPI app with Dapr integration
- `Dockerfile`: Containerization with Dapr sidecar
- `deployment.yaml`: Kubernetes deployment with Dapr annotation
- `requirements.txt`: Dependencies including FastAPI, Dapr, OpenAI
- Health check endpoints and proper error handling

## Security Considerations
- Dapr sidecar handles authentication and authorization
- Secrets stored securely using Dapr secret management
- Rate limiting to prevent abuse
- Input validation and sanitization

## Observability
- Distributed tracing with Dapr
- Metrics collection for performance monitoring
- Structured logging for debugging
- Health check endpoints

## Deployment Process
1. Generate service structure with templates
2. Build container image
3. Deploy to Kubernetes with Dapr sidecar injection
4. Configure Dapr components for state and pub/sub
5. Verify service health and connectivity
