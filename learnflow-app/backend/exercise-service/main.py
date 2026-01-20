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

app = FastAPI(title="LearnFlow Exercise Service", version="1.0.0")


class QueryRequest(BaseModel):
    query_id: str
    student_id: str
    session_id: str
    query: str
    context: Dict[str, Any] = {}
    routed_from: str = "triage"
    timestamp: str = ""


class ExerciseResponse(BaseModel):
    query_id: str
    student_id: str
    content: str
    response_type: str = "exercise-generation"
    ai_provider: str = "OpenAI"
    ai_model: str = "gpt-4o-mini"
    timestamp: str


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "exercise-service",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/api/process-exercise")
async def process_exercise_query(query_request: QueryRequest):
    """Process exercise generation query using AI"""
    try:
        # Log the received query
        logger.info(f"Processing exercise query: {query_request.query}")

        # Prepare the AI prompt for exercise generation
        prompt = f"""
        Generate a Python programming exercise based on the following request:
        "{query_request.query}"

        Provide:
        1. A clear problem statement
        2. A starter code template
        3. Sample test cases
        4. Expected output examples
        5. Learning objectives
        6. Difficulty level assessment

        Format the response in a clear, educational way suitable for students.
        """

        # Use OpenAI to generate the exercise
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
                {"role": "system", "content": "You are an expert Python educator. Create engaging programming exercises."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=int(os.getenv("OPENAI_MAX_TOKENS", "2000")),
            temperature=float(os.getenv("OPENAI_TEMPERATURE", "0.7"))
        )

        exercise_content = response.choices[0].message.content

        # Create response
        exercise_response = ExerciseResponse(
            query_id=query_request.query_id,
            student_id=query_request.student_id,
            content=exercise_content,
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
                    "content": exercise_content,
                    "response_type": "exercise-generation",
                    "source_service": "exercise-service",
                    "timestamp": datetime.utcnow().isoformat()
                }),
                data_content_type='application/json'
            )

        return exercise_response

    except Exception as e:
        logger.error(f"Error processing exercise query: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing exercise query: {str(e)}")


@app.get("/api/stats")
async def get_stats():
    """Get service statistics"""
    return {
        "service": "exercise-service",
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