# Agents MD Generator - Detailed Documentation

## Overview
The Agents MD Generator skill analyzes repository structures to identify and document AI agent components. It creates a comprehensive AGENTS.md file that serves as a central documentation hub for all AI agents in the project.

## Features
- Automatic detection of agent-related files and directories
- Generation of standardized agent documentation format
- Identification of agent dependencies and configurations
- Creation of usage examples and API documentation

## Technical Specifications
- Scans common agent file patterns: `*.agent`, `agent.*`, `*_agent.*`, `agents/**/*`
- Detects configuration files: `.env`, `config.json`, `settings.yaml`
- Identifies API endpoints and communication protocols
- Documents agent interactions and data flows

## Output Format
The generated AGENTS.md follows this structure:
```
# AI Agents Documentation

## Agent List
- [Agent Name](#agent-name) - Brief description

## Agent Details
### Agent Name
- **Type**: Agent category (LLM, Tool, Interface, etc.)
- **Purpose**: Primary function
- **Dependencies**: Required components
- **Configuration**: Setup parameters
- **Usage**: Example implementation
- **API Endpoints**: Available methods
```

## Implementation Details
The generator script:
1. Walks through the repository directory structure
2. Identifies agent-related files based on naming patterns
3. Analyzes code to extract agent properties
4. Generates markdown documentation with consistent formatting
5. Validates the output against documentation standards

## Customization
- Modify scan patterns in the configuration
- Adjust documentation templates
- Configure output location and naming
- Customize validation rules

## Troubleshooting
- If agents aren't detected, verify file naming follows recognized patterns
- Check that the repository has readable file permissions
- Ensure required dependencies are available for code analysis
