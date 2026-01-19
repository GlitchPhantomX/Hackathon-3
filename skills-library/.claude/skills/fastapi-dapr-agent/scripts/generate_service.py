#!/usr/bin/env python3
"""
FastAPI Dapr Agent - Service Generator
Generates FastAPI microservice with Dapr integration for AI agents.
"""

import os
import sys
import argparse
from pathlib import Path
import json


def load_template(template_path):
    """Load a template file."""
    with open(template_path, 'r') as f:
        return f.read()


def create_directory(path):
    """Create a directory if it doesn't exist."""
    os.makedirs(path, exist_ok=True)


def create_file(path, content):
    """Create a file with the given content."""
    with open(path, 'w') as f:
        f.write(content)


def generate_service(service_name, agent_type, output_dir):
    """Generate the complete service structure."""
    # Validate agent type
    valid_agent_types = ['triage', 'concepts', 'debug', 'exercise']
    if agent_type not in valid_agent_types:
        print(f"ERROR: Invalid agent type '{agent_type}'. Valid types: {valid_agent_types}")
        return False

    # Create output directory
    service_dir = Path(output_dir) / service_name
    create_directory(service_dir)

    # Define template directory
    template_dir = Path(__file__).parent / "templates"

    # Load templates
    try:
        main_template = load_template(template_dir / "main.py.template")
        dockerfile_template = load_template(template_dir / "Dockerfile.template")
        deployment_template = load_template(template_dir / "deployment.yaml.template")
        requirements_template = load_template(template_dir / "requirements.txt.template")
    except FileNotFoundError as e:
        print(f"ERROR: Template file not found: {e}")
        return False

    # Replace placeholders in templates
    replacements = {
        '{{AGENT_NAME}}': service_name,
        '{{AGENT_TYPE}}': agent_type,
        '{{IMAGE_NAME}}': f"{service_name}:latest"
    }

    def replace_placeholders(template, replacements):
        result = template
        for placeholder, value in replacements.items():
            result = result.replace(placeholder, value)
        return result

    # Generate files
    main_content = replace_placeholders(main_template, replacements)
    dockerfile_content = replace_placeholders(dockerfile_template, replacements)
    deployment_content = replace_placeholders(deployment_template, replacements)
    requirements_content = replace_placeholders(requirements_template, replacements)

    # Write files
    create_file(service_dir / "main.py", main_content)
    create_file(service_dir / "Dockerfile", dockerfile_content)
    create_file(service_dir / "deployment.yaml", deployment_content)
    create_file(service_dir / "requirements.txt", requirements_content)

    # Create additional files
    create_file(service_dir / ".dockerignore", "venv/\n__pycache__/\n*.pyc\n.git/")
    create_file(service_dir / "README.md", f"""# {service_name}

AI-powered microservice for {agent_type} operations using FastAPI and Dapr.

## Features
- FastAPI web framework
- Dapr integration for state management and pub/sub
- OpenAI SDK for agent logic
- Health and readiness checks
- Structured logging

## Endpoints
- `GET /health` - Health check
- `GET /ready` - Readiness check
- `POST /chat` - Main chat endpoint
- `GET /sessions/{{user_id}}` - User sessions

## Deployment
This service is designed to run with Dapr sidecar in Kubernetes.
""")

    print(f"SUCCESS: Service '{service_name}' generated successfully!")
    print(f"  - Agent type: {agent_type}")
    print(f"  - Location: {service_dir}")
    print(f"  - Files created: main.py, Dockerfile, deployment.yaml, requirements.txt")

    return True


def main():
    """Main function."""
    parser = argparse.ArgumentParser(description="Generate FastAPI Dapr agent service")
    parser.add_argument("service_name", help="Name of the service to generate")
    parser.add_argument("--agent-type", "-t",
                       choices=['triage', 'concepts', 'debug', 'exercise'],
                       required=True,
                       help="Type of agent to generate")
    parser.add_argument("--output-dir", "-o",
                       default=".",
                       help="Output directory for the generated service")

    args = parser.parse_args()

    success = generate_service(args.service_name, args.agent_type, args.output_dir)

    if success:
        print(f"\nService generation completed successfully!")
        print(f"To deploy: cd {args.service_name} && ../deploy.sh")
        return 0
    else:
        print("\nService generation failed!")
        return 1


if __name__ == "__main__":
    sys.exit(main())