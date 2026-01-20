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

app = FastAPI(title="LearnFlow Concepts Service", version="1.0.0")


class QueryRequest(BaseModel):
    query_id: str
    student_id: str
    session_id: str
    query: str
    context: Dict[str, Any] = {}
    routed_from: str = "triage"
    timestamp: str = ""


class ConceptResponse(BaseModel):
    query_id: str
    student_id: str
    content: str
    response_type: str = "explanation"
    ai_provider: str = "OpenAI"
    ai_model: str = "gpt-4o-mini"
    timestamp: str


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "concepts-service",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/api/process-query")
async def process_concept_query(query_request: QueryRequest):
    """Process concept explanation query using AI"""
    try:
        # Log the received query
        logger.info(f"Processing concept query: {query_request.query}")
        
        # Prepare the AI prompt
        prompt = f"""
        Explain the following Python programming concept in a clear, educational way suitable for a beginner:
        "{query_request.query}"
        
        Provide:
        1. A simple explanation
        2. Practical examples with code snippets
        3. Common use cases
        4. Tips for beginners
        
        Keep the explanation concise but comprehensive.
        """
        
        # Use OpenAI to generate the explanation
        import openai
        from dapr.conf import Settings
        from dapr.clients.grpc._state import StateItem
        
        # Get OpenAI API key from environment
        openai.api_key = os.getenv("OPENAI_API_KEY")
        openai_model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
        
        if not openai.api_key:
            raise HTTPException(status_code=500, detail="OpenAI API key not configured")
        
        # Create OpenAI client
        client = openai.OpenAI(api_key=openai.api_key)
        
        # Call the OpenAI API
        response = client.chat.completions.create(
            model=openai_model,
            messages=[
                {"role": "system", "content": "You are an expert Python tutor. Explain concepts clearly with examples."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=int(os.getenv("OPENAI_MAX_TOKENS", "2000")),
            temperature=float(os.getenv("OPENAI_TEMPERATURE", "0.7"))
        )
        
        explanation = response.choices[0].message.content
        
        # Create response
        concept_response = ConceptResponse(
            query_id=query_request.query_id,
            student_id=query_request.student_id,
            content=explanation,
            timestamp=datetime.utcnow().isoformat()
        )
        
        # Publish response to Kafka via Dapr
        with DaprClient() as dapr_client:
            dapr_client.publish_event(
                pubsub_name="kafka-pubsub",
                topic_name="learning.response",
                data=json.dumps({
                    "query_id": query_request.query_id,
                    "student_id": query_request.student_id,
                    "content": explanation,
                    "response_type": "explanation",
                    "source_service": "concepts-service",
                    "timestamp": datetime.utcnow().isoformat()
                }),
                data_content_type='application/json'
            )
        
        return concept_response
        
    except Exception as e:
        logger.error(f"Error processing concept query: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing concept query: {str(e)}")


@app.get("/api/stats")
async def get_stats():
    """Get service statistics"""
    return {
        "service": "concepts-service",
        "status": "operational",
        "ai_model": os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        "processed_queries": 0
    }


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        workers=1
    )
