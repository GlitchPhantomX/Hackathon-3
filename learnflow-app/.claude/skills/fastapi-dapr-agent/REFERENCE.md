# FastAPI Dapr Agent Reference

## Architecture
The fastapi-dapr-agent skill creates a service architecture with:
- FastAPI application container
- Dapr sidecar container
- Kubernetes deployment with proper annotations
- Service mesh for communication

## Components
- FastAPI application with Dapr SDK integration
- Dapr sidecar for distributed capabilities
- Kubernetes manifests for deployment
- Dapr component configurations

## Dapr Integration
The skill configures Dapr building blocks:
- State management for persistent data
- Service invocation for service-to-service communication
- Publish-subscribe for event-driven architecture
- Secret management for secure credential access
- Bindings for external system integration

## Observability
Built-in observability features:
- Distributed tracing with Zipkin/Jaeger
- Metrics collection with Prometheus
- Structured logging
- Health checks and readiness probes