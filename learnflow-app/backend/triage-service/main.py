import asyncio
import json
import os
import uuid
from datetime import datetime
from typing import Dict, Any

import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import logging

# Import Dapr packages
from dapr.clients import DaprClient

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="LearnFlow Triage Service", version="1.0.0")


class StudentQuery(BaseModel):
    student_id: str
    session_id: str
    query: str
    context: Dict[str, Any] = {}


class TriageResponse(BaseModel):
    query_id: str
    student_id: str
    routed_to: str
    topic: str
    timestamp: str


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "triage-service",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/api/triage", response_model=TriageResponse)
async def triage_query(query_request: StudentQuery):
    """Submit a query for routing to appropriate specialist"""
    try:
        query_id = f"q-{query_request.student_id}-{uuid.uuid4()}"
        
        # Determine routing based on query content
        query_lower = query_request.query.lower()
        
        if any(keyword in query_lower for keyword in [
            "debug", "error", "fix", "problem", "not working", "exception", "bug", "traceback"
        ]):
            routed_to = "debug"
        elif any(keyword in query_lower for keyword in [
            "explain", "what is", "how does", "understand", "concept", "define", "meaning"
        ]):
            routed_to = "concepts"
        elif any(keyword in query_lower for keyword in [
            "exercise", "practice", "quiz", "test", "assignment", "problem", "challenge"
        ]):
            routed_to = "exercise"
        else:
            # Default to concepts if uncertain
            routed_to = "concepts"
        
        # Define the Kafka topic for routing
        topic = f"learning.query.{routed_to}"
        
        # Create response
        response = TriageResponse(
            query_id=query_id,
            student_id=query_request.student_id,
            routed_to=routed_to,
            topic=topic,
            timestamp=datetime.utcnow().isoformat()
        )
        
        # Log the routing decision
        logger.info(f"Query {query_id} routed to {routed_to} service")
        
        # Publish to Kafka topic via Dapr
        with DaprClient() as dapr_client:
            # Publish the query to the appropriate topic
            dapr_client.publish_event(
                pubsub_name="kafka-pubsub",
                topic_name=topic,
                data=json.dumps({
                    "query_id": query_id,
                    "student_id": query_request.student_id,
                    "session_id": query_request.session_id,
                    "query": query_request.query,
                    "context": query_request.context,
                    "routed_from": "triage",
                    "timestamp": datetime.utcnow().isoformat()
                }),
                data_content_type='application/json'
            )

            # Also publish acknowledgment to learning.response topic
            dapr_client.publish_event(
                pubsub_name="kafka-pubsub",
                topic_name="learning.response",
                data=json.dumps({
                    "query_id": query_id,
                    "student_id": query_request.student_id,
                    "message_type": "acknowledgment",
                    "content": f"Your query has been routed to the {routed_to} service for processing.",
                    "timestamp": datetime.utcnow().isoformat()
                }),
                data_content_type='application/json'
            )
        
        return response
        
    except Exception as e:
        logger.error(f"Error processing query: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing query: {str(e)}")


@app.get("/api/stats")
async def get_stats():
    """Get service statistics"""
    return {
        "service": "triage-service",
        "status": "operational",
        "routing_rules": {
            "debug_keywords": ["debug", "error", "fix", "problem", "not working", "exception", "bug"],
            "concepts_keywords": ["explain", "what is", "how does", "understand", "concept", "define"],
            "exercise_keywords": ["exercise", "practice", "quiz", "test", "assignment"]
        }
    }


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        workers=1
    )
