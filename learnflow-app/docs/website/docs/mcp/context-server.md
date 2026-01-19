# LearnFlow Context MCP Server

The LearnFlow Context MCP Server provides contextual information to AI agents about student progress, exercises, and code submissions. This enables AI agents to provide personalized and relevant responses based on the student's current learning state.

## Overview

The MCP (Model Context Protocol) server exposes a set of tools that AI agents can use to retrieve information about:

- Student progress and mastery levels
- Available exercises and practice problems
- Code submission history
- Areas where students are struggling

## Available Tools

### getStudentProgress
Retrieves a student's overall progress data.

**Input Schema:**
```json
{
  "userId": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "userId": "string",
      "moduleId": "string",
      "progress": 0,
      "mastery": 0,
      "lastAccessed": "date",
      "completed": true
    }
  ],
  "message": "string"
}
```

### getStudentProgressByModule
Retrieves a student's progress for a specific module.

**Input Schema:**
```json
{
  "userId": "string",
  "moduleId": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "string",
    "userId": "string",
    "moduleId": "string",
    "progress": 0,
    "mastery": 0,
    "lastAccessed": "date",
    "completed": true
  },
  "message": "string"
}
```

### getExercisesByTopic
Retrieves exercises by topic and difficulty level.

**Input Schema:**
```json
{
  "topic": "string",
  "difficulty": "easy|medium|hard" (optional)
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "topic": "string",
      "difficulty": "easy|medium|hard",
      "content": "string",
      "createdAt": "date"
    }
  ],
  "message": "string"
}
```

### getCodeSubmissionHistory
Retrieves a student's code submission history.

**Input Schema:**
```json
{
  "userId": "string",
  "moduleId": "string" (optional)
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "userId": "string",
      "moduleId": "string",
      "code": "string",
      "submittedAt": "date",
      "executionResult": "string",
      "grade": 0 (optional)
    }
  ],
  "message": "string"
}
```

### getExerciseById
Retrieves a specific exercise by its ID.

**Input Schema:**
```json
{
  "exerciseId": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "string",
    "title": "string",
    "description": "string",
    "topic": "string",
    "difficulty": "easy|medium|hard",
    "content": "string",
    "createdAt": "date"
  },
  "message": "string"
}
```

### getStudentStruggles
Identifies areas where a student is struggling based on progress data.

**Input Schema:**
```json
{
  "userId": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "moduleId": "string",
      "mastery": 0,
      "title": "string"
    }
  ],
  "message": "string"
}
```

## Configuration

The MCP server is configured with the following settings:

- **Name**: LearnFlow Context Server
- **Description**: Provides context about student progress, exercises, and code submissions
- **Version**: 1.0.0
- **Endpoint**: `/mcp`
- **Health Check**: `/health`

## Integration

The MCP server connects to the LearnFlow backend to retrieve real-time data about students and exercises. In a production environment, it would connect to the actual database and API services, while in development it may use mock data.

## Security

- All endpoints are secured with appropriate authentication
- Input validation is performed using Zod schemas
- Rate limiting is implemented to prevent abuse
- Sensitive data is filtered before transmission