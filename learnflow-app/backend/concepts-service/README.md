# Concepts Service

The Concepts Service is responsible for explaining Python programming concepts to students using AI-powered explanations.

## Purpose

The concepts service handles queries that seek explanations of programming concepts, syntax, or language features. It uses OpenAI's API to generate clear, educational explanations with practical examples.

## Functionality

- Processes concept explanation requests from the triage service
- Generates detailed explanations using AI
- Provides code examples and best practices
- Publishes responses back to the learning system

## Endpoints

- `GET /health`: Health check endpoint
- `POST /api/process-query`: Process concept explanation query using AI
- `GET /api/stats`: Get service statistics

## Architecture

- Built with FastAPI
- Uses Dapr for service mesh capabilities
- Communicates via Kafka pub/sub pattern
- Integrates with OpenAI for AI-powered explanations
- Containerized with Docker
- Deployed on Kubernetes

## Configuration

The service uses the following environment variables from the backend config:
- OpenAI API key and model settings
- Kafka connection settings
- Service configuration
- Logging level
