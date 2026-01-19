from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import Optional, Dict, Any
import asyncio
import logging
import json
import os

# Import Dapr client
from dapr.clients import DaprClient
from dapr.ext.fastapi import DaprApp

app = FastAPI(title="exercise-service", description="AI agent service", version="1.0.0")

# Initialize Dapr app
dapr_app = DaprApp(app)
client = DaprClient()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Models
class ChatRequest(BaseModel):
    user_id: str
    message: str
    session_id: Optional[str] = None
    context: Optional[Dict[str, Any]] = None

class ChatResponse(BaseModel):
    response: str
    session_id: str
    metadata: Optional[Dict[str, Any]] = None

class EventPayload(BaseModel):
    event_type: str
    data: Dict[str, Any]

@app.on_event('startup')
async def startup_event():
    logger.info("exercise-service service starting up...")
    # Initialize any required resources
    pass

@app.on_event('shutdown')
async def shutdown_event():
    logger.info("exercise-service service shutting down...")
    client.close()

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "exercise-service"}

@app.get("/ready")
async def readiness_check():
    """Readiness check endpoint"""
    # Check if Dapr sidecar is available
    try:
        with DaprClient() as dapr_client:
            # Test state store connection
            dapr_client.wait(10)  # Wait up to 10 seconds for Dapr
        return {"status": "ready", "service": "exercise-service"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Dapr not ready: {str(e)}")

@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest, background_tasks: BackgroundTasks):
    """
    Main chat endpoint for the exercise agent
    """
    try:
        logger.info(f"Received chat request from user {request.user_id}")

        # Generate session ID if not provided
        session_id = request.session_id or f"session_{hash(request.user_id + str(hash(request.message)))}"

        # Retrieve session state from Dapr state store
        state_key = f"{request.user_id}:{session_id}"
        try:
            with DaprClient() as dapr_client:
                state_response = dapr_client.get_state(
                    store_name="statestore",
                    key=state_key
                )
                session_state = json.loads(state_response.data.decode()) if state_response.data else {}
        except Exception as e:
            logger.warning(f"Could not retrieve session state: {e}")
            session_state = {}

        # Process the request with the AI agent
        response_text = await process_agent_request(request, session_state)

        # Update session state
        session_state.update({
            "last_message": request.message,
            "last_response": response_text,
            "timestamp": asyncio.get_event_loop().time()
        })

        try:
            with DaprClient() as dapr_client:
                dapr_client.save_state(
                    store_name="statestore",
                    key=state_key,
                    value=json.dumps(session_state)
                )
        except Exception as e:
            logger.error(f"Could not save session state: {e}")

        # Publish event to Kafka topic
        background_tasks.add_task(
            publish_event,
            "agent_interaction",
            {
                "user_id": request.user_id,
                "session_id": session_id,
                "input": request.message,
                "output": response_text,
                "agent_type": "exercise"
            }
        )

        return ChatResponse(
            response=response_text,
            session_id=session_id
        )
    except Exception as e:
        logger.error(f"Error processing chat request: {e}")
        raise HTTPException(status_code=500, detail=str(e))

async def process_agent_request(request: ChatRequest, session_state: Dict[str, Any]) -> str:
    """
    Process the agent-specific request logic
    """
    # This is where the AI agent logic would go
    # For now, return a placeholder response based on agent type
    agent_responses = {
        "triage": f"I'm the triage agent. I received your message: '{request.message}'. I can route this to the appropriate service.",
        "concepts": f"I'm the concepts agent. Your question about '{request.message}' relates to programming concepts. I can explain this in detail.",
        "debug": f"I'm the debug agent. Looking at your code issue: '{request.message}', I can help identify and fix the problem.",
        "exercise": f"I'm the exercise agent. Based on '{request.message}', I can generate a suitable coding challenge for you."
    }

    # In a real implementation, this would call the OpenAI API
    # For now, return a placeholder response
    return agent_responses.get("exercise", f"exercise agent received: {request.message}")

async def publish_event(event_type: str, data: Dict[str, Any]):
    """
    Publish an event to Kafka via Dapr pub/sub
    """
    try:
        with DaprClient() as dapr_client:
            dapr_client.publish_event(
                pubsub_name="pubsub",
                topic_name=event_type,
                data=json.dumps(data),
                data_content_type='application/json'
            )
        logger.info(f"Published event: {event_type}")
    except Exception as e:
        logger.error(f"Failed to publish event {event_type}: {e}")

@app.get("/sessions/{user_id}")
async def get_user_sessions(user_id: str):
    """
    Retrieve all sessions for a user (example of state query)
    """
    # Note: This is a simplified example. In practice, you'd need to store session IDs separately
    # or use a state store that supports querying
    try:
        with DaprClient() as dapr_client:
            # Try to get a specific session state as an example
            state_response = dapr_client.get_state(
                store_name="statestore",
                key=f"{user_id}:current"
            )
            if state_response.data:
                return {"user_id": user_id, "session_data": json.loads(state_response.data.decode())}
            else:
                return {"user_id": user_id, "sessions": []}
    except Exception as e:
        logger.error(f"Error retrieving sessions for user {user_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)