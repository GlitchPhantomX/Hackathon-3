# Backend API Reference

This document describes the API endpoints provided by the LearnFlow backend service.

## Authentication

### Login
```
POST /auth/login
```

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "access_token": "string",
  "token_type": "bearer",
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "role": "student|teacher"
  }
}
```

### Register
```
POST /auth/register
```

**Request Body:**
```json
{
  "email": "string",
  "password": "string",
  "name": "string",
  "role": "student|teacher"
}
```

**Response:**
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "role": "student|teacher"
}
```

## Modules

### Get All Modules
```
GET /modules
```

**Response:**
```json
[
  {
    "id": "string",
    "title": "string",
    "description": "string",
    "order": 0,
    "lessons": []
  }
]
```

### Get Module by ID
```
GET /modules/{module_id}
```

**Response:**
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "order": 0,
  "lessons": [
    {
      "id": "string",
      "title": "string",
      "content": "string",
      "order": 0
    }
  ]
}
```

## Progress

### Update Module Progress
```
PUT /modules/{module_id}/progress
```

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "progress": 0,
  "mastery": 0
}
```

**Response:**
```json
{
  "id": "string",
  "user_id": "string",
  "module_id": "string",
  "progress": 0,
  "mastery": 0
}
```

### Get User Progress
```
GET /progress/user/{user_id}
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
[
  {
    "id": "string",
    "module_id": "string",
    "progress": 0,
    "mastery": 0,
    "completed": true
  }
]
```

## Code Execution

### Execute Python Code
```
POST /code/execute
```

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "code": "string",
  "language": "python"
}
```

**Response:**
```json
{
  "output": "string",
  "errors": "string",
  "execution_time": 0
}
```

## Chat

### Send Chat Message
```
POST /chat/message
```

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "message": "string",
  "conversation_id": "string"
}
```

**Response:**
```json
{
  "id": "string",
  "sender_id": "string",
  "message": "string",
  "timestamp": "datetime"
}
```

## Exercises

### Get Exercises by Topic
```
GET /exercises/topic/{topic}
```

**Query Parameters:**
- `difficulty`: easy|medium|hard (optional)

**Response:**
```json
[
  {
    "id": "string",
    "title": "string",
    "description": "string",
    "topic": "string",
    "difficulty": "easy|medium|hard",
    "content": "string"
  }
]
```