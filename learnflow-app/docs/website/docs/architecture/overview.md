# Architecture Overview

LearnFlow follows a modern microservices architecture designed for scalability, maintainability, and performance. The system consists of several interconnected services that work together to provide an engaging Python learning experience.

## System Components

### Frontend Service
- Built with Next.js 14 using the App Router
- TypeScript for type safety
- Tailwind CSS for responsive styling
- Monaco Editor for code editing
- Real-time WebSocket connections for chat functionality
- Role-based access control for students and teachers

### Backend Service
- FastAPI framework for high-performance API endpoints
- PostgreSQL database for persistent data storage
- SQLAlchemy ORM for database interactions
- Pydantic for data validation
- Support for code execution in isolated environments
- RESTful API design with comprehensive documentation

### Triage Agent
- AI-powered query routing system
- Determines the appropriate agent for student questions
- Uses language models to classify query types
- Integrates with the MCP protocol for context awareness
- Routes to Concepts agent for Python concept explanations

### Concepts Agent
- Specialized AI agent for Python concept explanations
- Provides detailed, contextual responses to student queries
- Generates code examples and exercises
- Maintains conversation history for continuity
- Integrates with the learning management system

### Message Queue
- Apache Kafka for asynchronous processing
- Handles code execution requests
- Processes learning analytics
- Manages notification delivery
- Ensures reliable message delivery

## Data Flow

1. Students interact with the frontend application
2. Queries are sent to the Triage Agent for classification
3. The Triage Agent routes queries to appropriate specialized agents
4. Responses are sent back through the system to the frontend
5. Learning progress is tracked and stored in the database
6. Analytics are processed asynchronously via Kafka

## Infrastructure

The application is deployed on Kubernetes with the following infrastructure components:

- Service mesh for inter-service communication
- Load balancers for traffic distribution
- Persistent volumes for data storage
- Horizontal pod autoscaling for demand-based scaling
- Monitoring and logging systems for observability