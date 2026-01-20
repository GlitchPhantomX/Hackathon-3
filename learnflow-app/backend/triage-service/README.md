# Triage Service

The Triage Service is responsible for routing student queries to the appropriate specialist services based on the content and context of the query.

## Purpose

The triage service acts as the entry point for all student queries in the LearnFlow platform. It analyzes incoming queries and routes them to the most appropriate specialist service:
- **Concepts Service**: For queries asking for explanations of programming concepts
- **Debug Service**: For queries seeking help with code errors and debugging
- **Exercise Service**: For queries requesting practice exercises

## Functionality

The service uses keyword analysis to categorize queries and route them appropriately. It publishes messages to the corresponding Kafka topics based on the determined category.

## Endpoints

- `GET /health`: Health check endpoint
- `POST /api/triage`: Submit a query for routing to appropriate specialist
- `GET /api/stats`: Get service statistics

## Architecture

- Built with FastAPI
- Uses Dapr for service mesh capabilities
- Communicates via Kafka pub/sub pattern
- Containerized with Docker
- Deployed on Kubernetes

## Configuration

The service uses the following environment variables from the backend config:
- Kafka connection settings
- Service configuration
- Logging level
