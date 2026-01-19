#!/usr/bin/env python3
"""
Reusable MCP Client Template
Template for converting MCP servers to code execution pattern.
"""

import os
import json
import sys
import requests
from typing import Dict, Any, Optional, Callable
from abc import ABC, abstractmethod


class MCPClientTemplate(ABC):
    """
    Abstract base class for MCP client wrappers.
    Provides token-efficient patterns for wrapping MCP servers.
    """

    def __init__(self, server_url: str, auth_token: Optional[str] = None):
        self.server_url = server_url.rstrip('/')
        self.auth_token = auth_token
        self.session = requests.Session()

        if auth_token:
            self.session.headers.update({"Authorization": f"Bearer {auth_token}"})

        self.session.headers.update({"Content-Type": "application/json"})

    def _make_request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict[str, Any]:
        """Make HTTP request to the MCP server."""
        url = f"{self.server_url}{endpoint}"

        try:
            if method.upper() == "GET":
                response = self.session.get(url)
            elif method.upper() == "POST":
                response = self.session.post(url, json=data)
            elif method.upper() == "PUT":
                response = self.session.put(url, json=data)
            elif method.upper() == "DELETE":
                response = self.session.delete(url)
            else:
                return {"success": False, "error": f"Unsupported method: {method}"}

            response.raise_for_status()
            return {"success": True, "data": response.json()}

        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}

    @abstractmethod
    def get_token_efficient_response(self, raw_response: Dict[str, Any]) -> Dict[str, Any]:
        """
        Abstract method to transform raw MCP response into token-efficient format.
        Implement this in subclasses to filter and reduce response size.
        """
        pass

    def call_operation(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict[str, Any]:
        """Call an operation on the MCP server and return token-efficient response."""
        raw_response = self._make_request(method, endpoint, data)

        if raw_response["success"]:
            return self.get_token_efficient_response(raw_response["data"])
        else:
            return {"success": False, "error": raw_response["error"]}


class GenericMCPWrapper(MCPClientTemplate):
    """
    Generic wrapper for MCP servers with customizable response filtering.
    """

    def __init__(self, server_url: str, auth_token: Optional[str] = None,
                 field_filter: Optional[Callable[[Dict], Dict]] = None):
        super().__init__(server_url, auth_token)
        self.field_filter = field_filter or self._default_field_filter

    def _default_field_filter(self, data: Dict) -> Dict:
        """Default method to filter response data for token efficiency."""
        if isinstance(data, dict):
            # Preserve only essential fields
            essential_fields = {"id", "name", "status", "result", "success", "message", "type", "title", "value"}

            filtered = {}
            for key, value in data.items():
                if key in essential_fields:
                    if isinstance(value, (str, int, float, bool)):
                        # For simple values, include as-is
                        filtered[key] = value
                    elif isinstance(value, list) and len(value) <= 10:
                        # For small lists, include as-is
                        filtered[key] = value
                    elif isinstance(value, dict):
                        # Recursively filter nested dicts
                        filtered[key] = self._default_field_filter(value)
                    else:
                        # For complex values, convert to string representation
                        filtered[key] = str(value)[:100]  # Limit length
                elif key == "items" and isinstance(value, list):
                    # Special handling for 'items' arrays - limit and filter each item
                    filtered_items = []
                    for item in value[:5]:  # Limit to 5 items
                        if isinstance(item, dict):
                            filtered_items.append(self._default_field_filter(item))
                        else:
                            filtered_items.append(str(item)[:100])
                    filtered[key] = filtered_items

            return filtered
        else:
            # If not a dict, return as-is (but limit length)
            if isinstance(data, str) and len(data) > 500:
                return data[:500] + "... [truncated]"
            return data

    def get_token_efficient_response(self, raw_response: Dict[str, Any]) -> Dict[str, Any]:
        """Return the token-efficient version of the response."""
        return self.field_filter(raw_response)

    def get_resource(self, resource_id: str, endpoint_base: str) -> Dict[str, Any]:
        """Get a specific resource with token-efficient response."""
        endpoint = f"{endpoint_base}/{resource_id}"
        return self.call_operation("GET", endpoint)

    def list_resources(self, endpoint: str, limit: int = 10) -> Dict[str, Any]:
        """List resources with token-efficient response."""
        # Add limit parameter to reduce response size
        endpoint = f"{endpoint}?limit={limit}"
        return self.call_operation("GET", endpoint)

    def create_resource(self, endpoint: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a resource and return token-efficient response."""
        return self.call_operation("POST", endpoint, data)

    def update_resource(self, resource_id: str, endpoint_base: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Update a resource and return token-efficient response."""
        endpoint = f"{endpoint_base}/{resource_id}"
        return self.call_operation("PUT", endpoint, data)


def create_custom_wrapper(server_url: str, field_filter: Callable[[Dict], Dict]) -> GenericMCPWrapper:
    """
    Factory function to create a custom MCP wrapper with specific field filtering.
    """
    return GenericMCPWrapper(server_url, field_filter=field_filter)


def main():
    """Example usage of the MCP client template."""
    if len(sys.argv) < 3:
        print("Usage: mcp_client_template.py <server_url> <operation> [args...]")
        print("Operations: get <endpoint>, list <endpoint>, create <endpoint> <json_data>")
        return 1

    server_url = sys.argv[1]
    operation = sys.argv[2]

    # Create a generic wrapper
    wrapper = GenericMCPWrapper(server_url)

    if operation == "get" and len(sys.argv) > 3:
        endpoint = sys.argv[3]
        result = wrapper.call_operation("GET", endpoint)
        print(json.dumps(result, indent=2))

    elif operation == "list" and len(sys.argv) > 3:
        endpoint = sys.argv[3]
        result = wrapper.list_resources(endpoint)
        print(json.dumps(result, indent=2))

    elif operation == "create" and len(sys.argv) > 4:
        endpoint = sys.argv[3]
        try:
            data = json.loads(sys.argv[4])
            result = wrapper.create_resource(endpoint, data)
            print(json.dumps(result, indent=2))
        except json.JSONDecodeError:
            print("Error: Invalid JSON data", file=sys.stderr)
            return 1

    else:
        print(f"Unknown operation: {operation}", file=sys.stderr)
        print("Usage: mcp_client_template.py <server_url> <operation> [args...]")
        print("Operations: get <endpoint>, list <endpoint>, create <endpoint> <json_data>")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())