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

app = FastAPI(title="LearnFlow Debug Service", version="1.0.0")


class QueryRequest(BaseModel):
    query_id: str
    student_id: str
    session_id: str
    query: str
    code: str = ""
    error_message: str = ""
    context: Dict[str, Any] = {}
    routed_from: str = "triage"
    timestamp: str = ""


class DebugResponse(BaseModel):
    query_id: str
    student_id: str
    content: str
    response_type: str = "debugging-assistance"
    ai_provider: str = "OpenAI"
    ai_model: str = "gpt-4o-mini"
    timestamp: str


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "debug-service",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/api/process-debug")
async def process_debug_query(query_request: QueryRequest):
    """Process debugging query using AI"""
    try:
        # Log the received query
        logger.info(f"Processing debug query: {query_request.query}")
        
        # Prepare the AI prompt for debugging
        prompt = f"""
        You are an expert Python debugger. Analyze the following code and error:

        Code:
        {query_request.code}

        Error Message:
        {query_request.error_message}

        User Query:
        {query_request.query}

        Provide:
        1. Clear explanation of what's wrong
        2. Corrected code with fixes
        3. Explanation of the fix
        4. Tips to prevent similar errors in the future
        5. Any best practices related to the issue

        Format your response clearly with headers and code examples.
        """
        
        # Use OpenAI to generate the debugging response
        import openai
        
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
                {"role": "system", "content": "You are an expert Python debugger. Provide clear, educational debugging help."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=int(os.getenv("OPENAI_MAX_TOKENS", "2000")),
            temperature=float(os.getenv("OPENAI_TEMPERATURE", "0.7"))
        )
        
        debug_analysis = response.choices[0].message.content
        
        # Create response
        debug_response = DebugResponse(
            query_id=query_request.query_id,
            student_id=query_request.student_id,
            content=debug_analysis,
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
                    "content": debug_analysis,
                    "response_type": "debugging-assistance",
                    "source_service": "debug-service",
                    "timestamp": datetime.utcnow().isoformat()
                }),
                data_content_type='application/json'
            )
        
        return debug_response
        
    except Exception as e:
        logger.error(f"Error processing debug query: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing debug query: {str(e)}")


@app.get("/api/stats")
async def get_stats():
    """Get service statistics"""
    return {
        "service": "debug-service",
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
