# LearnFlow Debug Service

The Debug Service is responsible for helping students debug their Python code by providing AI-powered error analysis and code correction suggestions.

## Purpose
- Analyzes code and error messages provided by students
- Provides clear explanations of what went wrong
- Offers corrected code with explanations
- Gives tips to prevent similar errors in the future

## Functionality
- Processes debugging requests from the triage service
- Analyzes code and error messages using AI
- Generates corrected code with detailed explanations
- Publishes debugging assistance back to the learning system

## Endpoints
- `GET /health`: Health check endpoint
- `POST /api/process-debug`: Process debugging query using AI
- `GET /api/stats`: Get service statistics

## Technologies Used
- FastAPI for web framework
- Dapr for service-to-service communication
- Kafka for event streaming
- OpenAI for intelligent debugging assistance
