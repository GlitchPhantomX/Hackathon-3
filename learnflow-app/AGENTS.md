# LearnFlow Agents Architecture

This document outlines the architecture, conventions, and guidelines for the LearnFlow AI agents ecosystem.

## Overview

LearnFlow uses a multi-agent system to provide personalized learning experiences. The system consists of specialized AI agents that work together to handle different aspects of the learning process.

## Agent Architecture

### 1. Triage Agent
The Triage Agent serves as the entry point for all student queries. Its responsibilities include:

- **Query Classification**: Determining the type and intent of student questions
- **Routing**: Directing queries to the appropriate specialized agent
- **Context Awareness**: Using MCP servers to understand student context
- **Fallback Handling**: Managing queries that don't fit standard categories

**Key Features:**
- Natural Language Processing for query understanding
- Confidence scoring for routing decisions
- Integration with context servers for personalized routing
- Fallback mechanisms for uncertain classifications

### 2. Concepts Agent
The Concepts Agent specializes in explaining Python programming concepts. Its responsibilities include:

- **Concept Explanation**: Providing detailed explanations of Python concepts
- **Code Examples**: Generating relevant code examples
- **Progress Adaptation**: Adjusting explanations based on student progress
- **Interactive Guidance**: Offering step-by-step guidance

**Key Features:**
- Deep knowledge of Python language features
- Ability to adapt explanations to different learning levels
- Integration with student progress data
- Generation of practice exercises

### 3. Exercise Agent (Future)
The Exercise Agent handles the generation and evaluation of programming exercises:

- **Exercise Generation**: Creating customized exercises based on learning objectives
- **Difficulty Adjustment**: Adapting exercise difficulty based on student performance
- **Solution Verification**: Checking student code against exercise requirements
- **Feedback Generation**: Providing constructive feedback on submissions

## MCP (Model Context Protocol) Integration

All agents utilize MCP servers to access contextual information:

### Context Server Capabilities
- **Student Progress**: Access to current progress and mastery levels
- **Learning History**: Historical data on student interactions
- **Personalization**: Ability to customize responses based on individual needs
- **Real-time Updates**: Current status of student activities

### MCP Tool Definitions
Agents can access various tools through MCP:

- `getStudentProgress(userId)`: Retrieve overall student progress
- `getStudentProgressByModule(userId, moduleId)`: Get progress for specific module
- `getExercisesByTopic(topic, difficulty?)`: Find relevant exercises
- `getCodeSubmissionHistory(userId, moduleId?)`: Access code history
- `getExerciseById(exerciseId)`: Retrieve specific exercise details
- `getStudentStruggles(userId)`: Identify challenging areas

## Conventions and Guidelines

### Naming Conventions
- **Agent Names**: Use descriptive names ending with "Agent" (e.g., TriageAgent, ConceptsAgent)
- **Function Names**: Use camelCase for agent functions
- **Configuration**: Use consistent prefixes for environment variables (e.g., `TRIAGE_AGENT_*`)

### Response Format Standards
All agents should follow a consistent response format:

```json
{
  "type": "information|query_response|exercise|feedback",
  "content": "string",
  "metadata": {
    "confidence": 0.0-1.0,
    "sources": ["array", "of", "relevant", "sources"],
    "follow_up": ["suggested", "next", "steps"]
  }
}
```

### Error Handling
- **Graceful Degradation**: Agents should provide useful responses even when context is limited
- **Fallback Mechanisms**: Have alternative responses when primary information sources are unavailable
- **User-Friendly Errors**: Convert technical errors to user-understandable messages

### Security Guidelines
- **Data Privacy**: Never expose sensitive student data in responses
- **Input Sanitization**: Validate and sanitize all inputs before processing
- **Rate Limiting**: Implement rate limiting to prevent abuse
- **Access Control**: Ensure agents only access authorized data

## Integration Patterns

### Agent Communication
- **Synchronous Calls**: For immediate query routing and response
- **Asynchronous Processing**: For complex operations that take time
- **Event-Based Communication**: For updates and notifications

### Context Propagation
- **Session State**: Maintain conversation context across agent interactions
- **Progress Tracking**: Update student progress based on agent interactions
- **Learning Analytics**: Collect data for improving the learning experience

## Development Guidelines

### Testing Strategy
- **Unit Tests**: Test individual agent functions
- **Integration Tests**: Test agent-to-agent communication
- **End-to-End Tests**: Test complete student interaction flows
- **Context Testing**: Verify MCP server integrations

### Monitoring and Observability
- **Performance Metrics**: Track agent response times and success rates
- **Usage Analytics**: Monitor which agents are most frequently used
- **Error Tracking**: Log and analyze agent failures
- **Learning Effectiveness**: Measure impact on student outcomes

## Best Practices

### For Agent Developers
1. **Modularity**: Keep agents focused on specific responsibilities
2. **Extensibility**: Design agents to accommodate future enhancements
3. **Documentation**: Maintain clear documentation for each agent's capabilities
4. **Testing**: Implement comprehensive testing for all agent behaviors

### For MCP Server Developers
1. **Data Freshness**: Ensure context data is up-to-date
2. **Performance**: Optimize queries to minimize latency
3. **Reliability**: Implement robust error handling and fallbacks
4. **Security**: Protect sensitive data and implement proper access controls

## Future Enhancements

### Planned Agents
- **Debugging Agent**: Specialized assistance for debugging student code
- **Project Agent**: Guidance for larger programming projects
- **Assessment Agent**: Automated quiz and exam generation
- **Motivation Agent**: Personalized encouragement and goal setting

### Advanced Features
- **Multi-modal Support**: Incorporate visual and audio learning aids
- **Collaborative Learning**: Facilitate peer-to-peer learning interactions
- **Adaptive Curriculum**: Dynamic adjustment of learning paths
- **Predictive Analytics**: Early identification of struggling students

## Troubleshooting

### Common Issues
- **Context Unavailability**: Implement graceful degradation when MCP servers are unavailable
- **Routing Errors**: Establish fallback routing for misclassified queries
- **Performance Bottlenecks**: Monitor and optimize agent response times
- **Data Consistency**: Handle scenarios where student data is inconsistent

### Debugging Tips
- Enable detailed logging for agent interactions
- Monitor MCP server availability and response times
- Track confidence scores to identify uncertain routing decisions
- Use A/B testing to evaluate agent effectiveness