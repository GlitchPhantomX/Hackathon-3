#!/usr/bin/env python3
"""
Slack MCP Wrapper Example
Demonstrates MCP to code execution pattern with token efficiency.
"""

import os
import json
import sys
import requests
from typing import Dict, List, Optional


class SlackWrapper:
    """Wrapper for Slack operations with token-efficient responses."""

    def __init__(self, token: str):
        self.token = token
        self.base_url = "https://slack.com/api"
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

    def get_channels(self) -> Dict:
        """
        Get channels with minimal response for token efficiency.
        """
        try:
            response = requests.get(
                f"{self.base_url}/conversations.list",
                headers=self.headers,
                params={
                    "types": "public_channel,private_channel",
                    "exclude_archived": "true",
                    "limit": 100  # Limit results for token efficiency
                }
            )
            response.raise_for_status()

            data = response.json()
            if not data.get("ok"):
                return {"success": False, "error": data.get("error", "Unknown error")}

            # Filter to only essential information
            filtered_channels = []
            for channel in data.get("channels", [])[:20]:  # Limit to 20 channels
                filtered_channel = {
                    "id": channel.get("id"),
                    "name": channel.get("name"),
                    "num_members": channel.get("num_members"),
                    "created": channel.get("created")
                }
                filtered_channels.append(filtered_channel)

            return {
                "success": True,
                "channel_count": len(filtered_channels),
                "channels": filtered_channels
            }

        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}

    def get_messages(self, channel_id: str, limit: int = 20) -> Dict:
        """
        Get messages from a channel with minimal response for token efficiency.
        """
        try:
            response = requests.get(
                f"{self.base_url}/conversations.history",
                headers=self.headers,
                params={
                    "channel": channel_id,
                    "limit": min(limit, 50)  # Maximum 50 for API limit
                }
            )
            response.raise_for_status()

            data = response.json()
            if not data.get("ok"):
                return {"success": False, "error": data.get("error", "Unknown error")}

            # Filter messages to only essential information
            filtered_messages = []
            for message in data.get("messages", [])[:limit]:
                # Skip bot messages and system messages for token efficiency
                subtype = message.get("subtype")
                if subtype in ["bot_message", "channel_join", "channel_leave"]:
                    continue

                # Truncate long messages for token efficiency
                text = message.get("text", "")
                if len(text) > 200:  # Limit to 200 chars
                    text = text[:200] + "... [truncated]"

                filtered_message = {
                    "ts": message.get("ts"),
                    "user": message.get("user"),
                    "text_preview": text,
                    "has_attachments": bool(message.get("attachments"))
                }

                filtered_messages.append(filtered_message)

            return {
                "success": True,
                "message_count": len(filtered_messages),
                "messages": filtered_messages
            }

        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}

    def post_message(self, channel_id: str, text: str) -> Dict:
        """
        Post a message to a channel with minimal response.
        """
        try:
            response = requests.post(
                f"{self.base_url}/chat.postMessage",
                headers=self.headers,
                json={
                    "channel": channel_id,
                    "text": text,
                    "as_user": True
                }
            )
            response.raise_for_status()

            data = response.json()
            if not data.get("ok"):
                return {"success": False, "error": data.get("error", "Unknown error")}

            return {
                "success": True,
                "message_ts": data.get("ts"),
                "channel": channel_id
            }

        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}

    def get_users(self) -> Dict:
        """
        Get users with minimal response for token efficiency.
        """
        try:
            response = requests.get(
                f"{self.base_url}/users.list",
                headers=self.headers,
                params={"limit": 100}
            )
            response.raise_for_status()

            data = response.json()
            if not data.get("ok"):
                return {"success": False, "error": data.get("error", "Unknown error")}

            # Filter to only essential information
            filtered_users = []
            for user in data.get("members", [])[:50]:  # Limit to 50 users
                # Skip bots and deleted users for token efficiency
                if user.get("deleted") or user.get("is_bot"):
                    continue

                filtered_user = {
                    "id": user.get("id"),
                    "name": user.get("name"),
                    "real_name": user.get("real_name"),
                    "is_admin": user.get("is_admin", False)
                }

                filtered_users.append(filtered_user)

            return {
                "success": True,
                "user_count": len(filtered_users),
                "users": filtered_users
            }

        except requests.exceptions.RequestException as e:
            return {"success": False, "error": str(e)}


def main():
    """Main function demonstrating token-efficient Slack operations."""
    if len(sys.argv) < 2:
        print("Usage: slack_example.py <operation> [args...]")
        print("Operations: get_channels, get_messages <channel_id>, post_message <channel_id> <text>, get_users")
        return 1

    operation = sys.argv[1]

    # Get token from environment
    token = os.environ.get("SLACK_TOKEN")
    if not token:
        print("Error: SLACK_TOKEN environment variable required", file=sys.stderr)
        return 1

    slack = SlackWrapper(token)

    if operation == "get_channels":
        result = slack.get_channels()
        print(json.dumps(result, indent=2))

    elif operation == "get_messages" and len(sys.argv) > 2:
        channel_id = sys.argv[2]
        result = slack.get_messages(channel_id)
        print(json.dumps(result, indent=2))

    elif operation == "post_message" and len(sys.argv) > 3:
        channel_id = sys.argv[2]
        text = " ".join(sys.argv[3:])
        result = slack.post_message(channel_id, text)
        print(json.dumps(result, indent=2))

    elif operation == "get_users":
        result = slack.get_users()
        print(json.dumps(result, indent=2))

    else:
        print(f"Unknown operation: {operation}", file=sys.stderr)
        print("Usage: slack_example.py <operation> [args...]")
        print("Operations: get_channels, get_messages <channel_id>, post_message <channel_id> <text>, get_users")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())