#!/usr/bin/env python3
"""
Docusaurus Deploy - API Documentation Generator
Auto-generates API documentation from OpenAPI specs and source code.
"""

import os
import sys
import json
import yaml
import argparse
import subprocess
from pathlib import Path
from typing import Dict, List, Any, Optional


def find_openapi_specs(search_path: str) -> List[Path]:
    """Find OpenAPI specification files in the given path."""
    openapi_files = []
    search_path = Path(search_path)

    # Look for common OpenAPI spec files
    patterns = [
        "**/openapi.json",
        "**/openapi.yaml",
        "**/openapi.yml",
        "**/swagger.json",
        "**/swagger.yaml",
        "**/swagger.yml",
        "**/api/openapi.json",
        "**/api/openapi.yaml",
        "**/api/swagger.json",
        "**/api/swagger.yaml",
        "**/docs/openapi.json",
        "**/docs/openapi.yaml",
        "**/docs/swagger.json",
        "**/docs/swagger.yaml",
    ]

    for pattern in patterns:
        openapi_files.extend(search_path.glob(pattern))

    # Also look for files that might contain OpenAPI specs
    for ext in ['.json', '.yaml', '.yml']:
        for file_path in search_path.rglob(f"*{ext}"):
            if file_path.is_file():
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read(2048)  # Read first 2KB to check
                        if any(keyword in content.lower() for keyword in
                              ['openapi', 'swagger', 'info', 'paths', 'components']):
                            if file_path not in openapi_files:
                                openapi_files.append(file_path)
                except:
                    continue

    return openapi_files


def load_openapi_spec(spec_path: Path) -> Optional[Dict[str, Any]]:
    """Load an OpenAPI specification from a file."""
    try:
        with open(spec_path, 'r', encoding='utf-8') as f:
            if spec_path.suffix.lower() in ['.yaml', '.yml']:
                return yaml.safe_load(f)
            else:
                return json.load(f)
    except Exception as e:
        print(f"Error loading OpenAPI spec {spec_path}: {e}", file=sys.stderr)
        return None


def extract_api_info_from_code(search_path: str) -> List[Dict[str, Any]]:
    """Extract API information from source code comments and docstrings."""
    api_endpoints = []
    search_path = Path(search_path)

    # Look for common web framework route definitions
    for file_path in search_path.rglob("*.py"):
        if file_path.is_file():
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Look for FastAPI routes
                import re
                fastapi_pattern = r'(?:async\s+)?def\s+(\w+)\s*\([^)]*\):\s*(?:\n\s+"""(.*?)""")?.*?@(app|router)\.(get|post|put|delete|patch|options|head)\(["\']([^"\']+)["\']'
                matches = re.findall(fastapi_pattern, content, re.DOTALL | re.MULTILINE)

                for match in matches:
                    func_name, docstring, _, method, path = match
                    api_endpoints.append({
                        'type': 'fastapi',
                        'file': str(file_path),
                        'function': func_name,
                        'method': method.upper(),
                        'path': path,
                        'description': docstring.strip() if docstring else 'No description',
                        'parameters': [],  # Would need more sophisticated parsing
                        'responses': {}    # Would need more sophisticated parsing
                    })
            except Exception as e:
                print(f"Error parsing {file_path}: {e}", file=sys.stderr)
                continue

    # Look for other framework patterns
    for file_path in search_path.rglob("*.js"):
        if file_path.is_file():
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Look for Express.js routes
                express_pattern = r'app\.(get|post|put|delete|patch|options|head)\(["\']([^"\']+)["\'],'
                matches = re.findall(express_pattern, content)

                for method, path in matches:
                    api_endpoints.append({
                        'type': 'express',
                        'file': str(file_path),
                        'method': method.upper(),
                        'path': path,
                        'description': 'Express.js route',
                        'parameters': [],
                        'responses': {}
                    })
            except Exception as e:
                print(f"Error parsing {file_path}: {e}", file=sys.stderr)
                continue

    return api_endpoints


def generate_docusaurus_api_doc(api_spec: Dict[str, Any], output_dir: Path) -> Path:
    """Generate a Docusaurus markdown document from an OpenAPI spec."""
    title = api_spec.get('info', {}).get('title', 'API Documentation')
    version = api_spec.get('info', {}).get('version', '1.0.0')
    description = api_spec.get('info', {}).get('description', '')

    # Create the markdown content
    md_content = f"""---
sidebar_position: 2
---

# {title} API Documentation

**Version:** {version}

{description}

"""

    # Add paths section
    paths = api_spec.get('paths', {})
    if paths:
        md_content += "## API Endpoints\n\n"

        for path, methods in paths.items():
            for method, details in methods.items():
                summary = details.get('summary', details.get('description', 'No summary'))
                description = details.get('description', details.get('summary', ''))

                md_content += f"### {method.upper()} {path}\n\n"
                md_content += f"{description}\n\n"

                # Add parameters if available
                parameters = details.get('parameters', [])
                if parameters:
                    md_content += "**Parameters:**\n\n"
                    md_content += "| Name | Location | Type | Description |\n"
                    md_content += "|------|----------|------|-------------|\n"

                    for param in parameters:
                        name = param.get('name', 'N/A')
                        location = param.get('in', 'N/A')
                        param_type = param.get('schema', {}).get('type', 'N/A') if param.get('schema') else 'N/A'
                        desc = param.get('description', '')
                        md_content += f"| `{name}` | {location} | {param_type} | {desc} |\n"

                    md_content += "\n"

                # Add request body if available
                request_body = details.get('requestBody', {})
                if request_body:
                    content = request_body.get('content', {})
                    if content:
                        md_content += "**Request Body:**\n\n"
                        for content_type, schema_info in content.items():
                            example = schema_info.get('example', schema_info.get('schema', {}))
                            md_content += f"Content-Type: `{content_type}`\n\n"
                            if example:
                                md_content += "```json\n"
                                md_content += json.dumps(example, indent=2)
                                md_content += "\n```\n\n"

                # Add responses if available
                responses = details.get('responses', {})
                if responses:
                    md_content += "**Responses:**\n\n"
                    for status_code, response_info in responses.items():
                        desc = response_info.get('description', 'Response')
                        md_content += f"- `{status_code}`: {desc}\n"

                        content = response_info.get('content', {})
                        for content_type, schema_info in content.items():
                            example = schema_info.get('example', schema_info.get('schema', {}))
                            if example:
                                md_content += f"  - Content-Type: `{content_type}`\n"
                                md_content += "    ```json\n"
                                md_content += json.dumps(example, indent=4)
                                md_content += "\n    ```\n"

                    md_content += "\n"

    # Add components section if available
    components = api_spec.get('components', {})
    if components:
        md_content += "## Components\n\n"

        if 'schemas' in components:
            md_content += "### Schemas\n\n"
            for schema_name, schema_def in components['schemas'].items():
                md_content += f"#### {schema_name}\n\n"
                md_content += "```json\n"
                md_content += json.dumps(schema_def, indent=2)
                md_content += "\n```\n\n"

    # Write the markdown file
    safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).rstrip()
    safe_title = safe_title.lower().replace(' ', '-').replace('--', '-')
    filename = output_dir / f"{safe_title}-api.md"

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(md_content)

    return filename


def generate_code_api_docs(api_endpoints: List[Dict[str, Any]], output_dir: Path) -> Optional[Path]:
    """Generate API documentation from extracted code information."""
    if not api_endpoints:
        return None

    md_content = """---
sidebar_position: 3
---

# Code-Based API Documentation

This documentation is auto-generated from code comments and route definitions.

"""

    # Group endpoints by file
    endpoints_by_file = {}
    for endpoint in api_endpoints:
        file_path = endpoint['file']
        if file_path not in endpoints_by_file:
            endpoints_by_file[file_path] = []
        endpoints_by_file[file_path].append(endpoint)

    for file_path, endpoints in endpoints_by_file.items():
        md_content += f"## From {os.path.basename(file_path)}\n\n"

        for endpoint in endpoints:
            md_content += f"### {endpoint['method']} {endpoint['path']}\n\n"
            md_content += f"**Function:** `{endpoint['function']}`\n\n"
            md_content += f"**Description:** {endpoint['description']}\n\n"

            if endpoint['parameters']:
                md_content += "**Parameters:**\n"
                for param in endpoint['parameters']:
                    md_content += f"- `{param}`\n"
                md_content += "\n"

    # Write the markdown file
    filename = output_dir / "code-api-docs.md"

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(md_content)

    return filename


def main():
    """Main function to generate API documentation."""
    parser = argparse.ArgumentParser(description="Generate API documentation from OpenAPI specs and code")
    parser.add_argument("source_path", help="Path to search for OpenAPI specs and source code")
    parser.add_argument("--output-dir", "-o",
                       default="./docs/api-reference",
                       help="Output directory for generated docs")
    parser.add_argument("--docusaurus-path", "-d",
                       default=".",
                       help="Path to Docusaurus site root")

    args = parser.parse_args()

    # Validate source path
    if not Path(args.source_path).exists():
        print(f"Error: Source path {args.source_path} does not exist", file=sys.stderr)
        return 1

    # Create output directory
    output_dir = Path(args.docusaurus_path) / args.output_dir
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Searching for OpenAPI specs in: {args.source_path}")

    # Find OpenAPI specs
    openapi_specs = find_openapi_specs(args.source_path)
    print(f"Found {len(openapi_specs)} OpenAPI specification(s)")

    # Process each spec
    generated_docs = []
    for spec_path in openapi_specs:
        print(f"Processing: {spec_path}")
        spec_data = load_openapi_spec(spec_path)
        if spec_data:
            doc_path = generate_docusaurus_api_doc(spec_data, output_dir)
            generated_docs.append(doc_path)
            print(f"  -> Generated: {doc_path}")

    # Extract API info from code
    print(f"Extracting API information from code in: {args.source_path}")
    api_endpoints = extract_api_info_from_code(args.source_path)
    print(f"Found {len(api_endpoints)} API endpoint(s) in code")

    # Generate code-based API docs
    code_doc_path = generate_code_api_docs(api_endpoints, output_dir)
    if code_doc_path:
        generated_docs.append(code_doc_path)
        print(f"  -> Generated: {code_doc_path}")

    if generated_docs:
        print(f"\n✓ Generated {len(generated_docs)} API documentation file(s)")
        print("Files created:")
        for doc in generated_docs:
            print(f"  - {doc}")
    else:
        print("No API documentation was generated. Check if OpenAPI specs or API routes exist in the source code.")

    return 0


if __name__ == "__main__":
    sys.exit(main())