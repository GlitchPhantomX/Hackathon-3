# LearnFlow Exercise Service

The Exercise Service is responsible for generating Python programming exercises for students based on their learning needs and skill level.

## Purpose
- Generates programming exercises tailored to student needs
- Provides starter code templates for exercises
- Creates sample test cases and expected outputs
- Assesses difficulty levels and learning objectives

## Functionality
- Processes exercise generation requests from the triage service
- Creates educational programming challenges using AI
- Generates starter code, test cases, and learning objectives
- Publishes exercises back to the learning system

## Endpoints
- `GET /health`: Health check endpoint
- `POST /api/process-exercise`: Process exercise generation query using AI
- `GET /api/stats`: Get service statistics

## Technologies Used
- FastAPI for web framework
- Dapr for service-to-service communication
- Kafka for event streaming
- OpenAI for intelligent exercise generation
