#!/usr/bin/env python3
"""
Agents MD Generator
Automatically generates AGENTS.md documentation for AI agents in a repository.
"""

import os
import sys
import json
import yaml
from pathlib import Path
from typing import Dict, List, Optional


def find_agent_files(root_dir: str) -> Dict[str, List[str]]:
    """Find all agent-related files in the repository."""
    agent_patterns = [
        '*.agent', '*agent*', 'agents/**/*',
        '*.json', '*.yaml', '*.yml',  # Config files
        '*.py', '*.js', '*.ts', '*.go',  # Code files
        'Dockerfile*', '*config*', '*setting*'
    ]

    found_files = {
        'agent_files': [],
        'config_files': [],
        'code_files': [],
        'documentation': []
    }

    root_path = Path(root_dir)

    # Look for agent-related files
    for file_path in root_path.rglob('*'):
        if file_path.is_file():
            # Check if filename indicates it's an agent file
            if ('agent' in file_path.name.lower() or
                file_path.suffix == '.agent' or
                'agents' in file_path.parts):
                found_files['agent_files'].append(str(file_path))

            # Check for configuration files
            elif file_path.name.lower() in ['config.json', 'settings.json', 'config.yaml',
                                          'config.yml', '.env', 'env', 'settings.yaml', 'settings.yml']:
                found_files['config_files'].append(str(file_path))

            # Check for code files
            elif file_path.suffix in ['.py', '.js', '.ts', '.go', '.java', '.cpp', '.c', '.rb', '.php']:
                found_files['code_files'].append(str(file_path))

            # Check for documentation files
            elif 'readme' in file_path.name.lower() or 'doc' in file_path.name.lower():
                found_files['documentation'].append(str(file_path))

    return found_files


def analyze_code_structure(code_files: List[str]) -> Dict[str, any]:
    """Analyze code files to extract agent information."""
    agent_info = {}

    for file_path in code_files:
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

                # Look for agent-related keywords and patterns
                if any(keyword in content.lower() for keyword in ['agent', 'llm', 'ai', 'gpt', 'openai']):
                    # Extract basic information about the file
                    agent_info[file_path] = {
                        'size': len(content),
                        'has_agent_keywords': True,
                        'potential_agent': any(kw in content.lower() for kw in [
                            'class.*agent', 'def.*agent', 'function.*agent',
                            'agent.*=', 'create.*agent', 'new.*agent'
                        ])
                    }
        except Exception:
            continue

    return agent_info


def generate_agents_md(found_files: Dict[str, List[str]], code_analysis: Dict[str, any], output_path: str):
    """Generate the AGENTS.md file based on findings."""

    md_content = """# AI Agents Documentation

This document provides an overview of all AI agents in this repository.

## Agent List
"""

    # Add agent files to the list
    for agent_file in found_files.get('agent_files', []):
        agent_name = os.path.basename(agent_file).replace('.agent', '').replace('_', ' ').title()
        md_content += f"- [{agent_name}]({agent_file}) - Agent definition file\n"

    # Add code files that might contain agents
    for code_file in found_files.get('code_files', []):
        if code_file in code_analysis and code_analysis[code_file].get('potential_agent'):
            agent_name = os.path.splitext(os.path.basename(code_file))[0].replace('_', ' ').title()
            md_content += f"- [{agent_name}]({code_file}) - Potential agent implementation\n"

    md_content += "\n## Configuration Files\n"
    for config_file in found_files.get('config_files', []):
        md_content += f"- [{os.path.basename(config_file)}]({config_file})\n"

    md_content += "\n## Documentation\n"
    for doc_file in found_files.get('documentation', []):
        md_content += f"- [{os.path.basename(doc_file)}]({doc_file})\n"

    # Add detailed sections for each agent
    md_content += "\n## Agent Details\n"

    for agent_file in found_files.get('agent_files', []):
        agent_name = os.path.basename(agent_file).replace('.agent', '').replace('_', ' ').title()
        md_content += f"\n### {agent_name}\n"
        md_content += "- **Type**: Agent definition\n"
        md_content += "- **Purpose**: Defines agent behavior and configuration\n"
        md_content += f"- **Location**: `{agent_file}`\n"
        md_content += "- **Dependencies**: None or specified in file\n"
        md_content += "- **Usage**: See implementation details in file\n\n"

    # Add code-based agents
    for code_file in found_files.get('code_files', []):
        if code_file in code_analysis and code_analysis[code_file].get('potential_agent'):
            agent_name = os.path.splitext(os.path.basename(code_file))[0].replace('_', ' ').title()
            md_content += f"\n### {agent_name}\n"
            md_content += "- **Type**: Agent implementation\n"
            md_content += "- **Purpose**: Contains agent logic and functionality\n"
            md_content += f"- **Location**: `{code_file}`\n"
            md_content += "- **Dependencies**: See imports/requirements in file\n"
            md_content += "- **Usage**: See implementation details in file\n\n"

    md_content += """
## API Endpoints
See individual agent implementations for specific API endpoints.

## Environment Variables
Check configuration files for required environment variables.

## Setup Instructions
1. Install dependencies listed in requirements/config files
2. Set up environment variables as specified
3. Configure agent settings according to documentation
4. Run agents as specified in implementation files

## Contributing
See individual agent files for contribution guidelines.
"""

    # Write the content to the output file
    with open(output_path, 'w', encoding='utf-8', newline='') as f:
        f.write(md_content)


def main():
    """Main function to run the agent documentation generator."""
    try:
        # Get the root directory to scan (default to current directory)
        root_dir = sys.argv[1] if len(sys.argv) > 1 else '.'

        # Get the output path (default to AGENTS.md in root)
        output_path = sys.argv[2] if len(sys.argv) > 2 else os.path.join(root_dir, 'AGENTS.md')

        print(f"Scanning directory: {root_dir}")

        # Find all agent-related files
        found_files = find_agent_files(root_dir)

        # Analyze code files for agent information
        code_analysis = analyze_code_structure(found_files.get('code_files', []))

        # Generate the AGENTS.md file
        generate_agents_md(found_files, code_analysis, output_path)

        print(f"SUCCESS: AGENTS.md created successfully at: {output_path}")
        print(f"  - Found {len(found_files.get('agent_files', []))} agent files")
        print(f"  - Found {len(found_files.get('config_files', []))} config files")
        print(f"  - Found {len(found_files.get('code_files', []))} code files")
        print(f"  - Found {len(found_files.get('documentation', []))} documentation files")

        return 0

    except Exception as e:
        print(f"ERROR: Error generating AGENTS.md: {str(e)}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())