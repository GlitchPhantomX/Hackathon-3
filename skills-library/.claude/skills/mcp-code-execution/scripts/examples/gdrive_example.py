#!/usr/bin/env python3
"""
Google Drive MCP Wrapper Example
Demonstrates MCP to code execution pattern with token efficiency.
"""

import os
import json
import sys
from typing import Dict, List, Optional
import requests


class GoogleDriveWrapper:
    """Wrapper for Google Drive operations with token-efficient responses."""

    def __init__(self, access_token: str):
        self.access_token = access_token
        self.base_url = "https://www.googleapis.com/drive/v3"
        self.headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }

    def list_files(self, query: str = "", max_results: int = 10) -> Dict:
        """
        List files from Google Drive with minimal response for token efficiency.
        """
        params = {
            "pageSize": max_results,
            "fields": "files(id,name,mimeType,modifiedTime,size)"
        }

        if query:
            params["q"] = query

        try:
            response = requests.get(
                f"{self.base_url}/files",
                headers=self.headers,
                params=params
            )
            response.raise_for_status()

            data = response.json()
            # Filter to only essential information
            filtered_files = []
            for file in data.get("files", []):
                filtered_file = {
                    "id": file.get("id"),
                    "name": file.get("name"),
                    "type": file.get("mimeType"),
                    "updated": file.get("modifiedTime")
                }
                # Only include size if available and not a folder
                if file.get("mimeType") != "application/vnd.google-apps.folder":
                    filtered_file["size"] = file.get("size")

                filtered_files.append(filtered_file)

            return {
                "success": True,
                "file_count": len(filtered_files),
                "files": filtered_files
            }

        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}

    def get_file_content(self, file_id: str) -> Dict:
        """
        Get file content with filtered response.
        """
        try:
            # Get file metadata first
            metadata_resp = requests.get(
                f"{self.base_url}/files/{file_id}",
                headers=self.headers,
                params={"fields": "name,mimeType"}
            )
            metadata_resp.raise_for_status()
            metadata = metadata_resp.json()

            # Download content based on file type
            if metadata["mimeType"] == "application/vnd.google-apps.document":
                # Google Doc - export as text
                content_resp = requests.get(
                    f"{self.base_url}/files/{file_id}/export",
                    headers=self.headers,
                    params={"mimeType": "text/plain"}
                )
            else:
                # Regular file - download directly
                content_resp = requests.get(
                    f"{self.base_url}/files/{file_id}",
                    headers=self.headers,
                    params={"alt": "media"}
                )

            content_resp.raise_for_status()

            # For token efficiency, truncate long content
            content = content_resp.text
            if len(content) > 1000:  # Limit to 1000 chars
                content = content[:1000] + "... [truncated for token efficiency]"

            return {
                "success": True,
                "name": metadata["name"],
                "type": metadata["mimeType"],
                "content_preview": content,
                "content_length": len(content_resp.text)
            }

        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}

    def search_files(self, search_term: str) -> Dict:
        """
        Search for files with token-efficient response.
        """
        query = f"name contains '{search_term}'"
        return self.list_files(query=query, max_results=5)


def main():
    """Main function demonstrating token-efficient Google Drive operations."""
    if len(sys.argv) < 2:
        print("Usage: gdrive_example.py <operation> [args...]")
        print("Operations: list, search <term>, get <file_id>")
        return 1

    operation = sys.argv[1]

    # Get access token from environment
    access_token = os.environ.get("GOOGLE_DRIVE_TOKEN")
    if not access_token:
        print("Error: GOOGLE_DRIVE_TOKEN environment variable required", file=sys.stderr)
        return 1

    drive = GoogleDriveWrapper(access_token)

    if operation == "list":
        result = drive.list_files()
        print(json.dumps(result, indent=2))

    elif operation == "search" and len(sys.argv) > 2:
        search_term = sys.argv[2]
        result = drive.search_files(search_term)
        print(json.dumps(result, indent=2))

    elif operation == "get" and len(sys.argv) > 2:
        file_id = sys.argv[2]
        result = drive.get_file_content(file_id)
        print(json.dumps(result, indent=2))

    else:
        print(f"Unknown operation: {operation}", file=sys.stderr)
        print("Usage: gdrive_example.py <operation> [args...]")
        print("Operations: list, search <term>, get <file_id>")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())