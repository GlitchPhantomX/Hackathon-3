#!/usr/bin/env python3
"""
Kubernetes MCP Wrapper Example
Demonstrates MCP to code execution pattern with token efficiency.
"""

import os
import json
import sys
import subprocess
from typing import Dict, List, Optional


class KubernetesWrapper:
    """Wrapper for Kubernetes operations with token-efficient responses."""

    def __init__(self, kubeconfig_path: Optional[str] = None):
        self.kubeconfig = kubeconfig_path
        self.kubectl_cmd = ["kubectl"]
        if kubeconfig_path:
            self.kubectl_cmd.extend(["--kubeconfig", kubeconfig_path])

    def run_kubectl(self, args: List[str]) -> Dict:
        """Run kubectl command and return token-efficient result."""
        cmd = self.kubectl_cmd + args

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )

            return {
                "success": True,
                "stdout": result.stdout,
                "stderr": result.stderr
            }
        except subprocess.CalledProcessError as e:
            return {
                "success": False,
                "error": str(e),
                "returncode": e.returncode,
                "stderr": e.stderr
            }

    def get_pods(self, namespace: str = "default") -> Dict:
        """Get pods with minimal token-efficient response."""
        try:
            result = self.run_kubectl([
                "get", "pods",
                "-n", namespace,
                "-o", "json"
            ])

            if not result["success"]:
                return result

            pods_data = json.loads(result["stdout"])
            filtered_pods = []

            for pod in pods_data.get("items", []):
                metadata = pod.get("metadata", {})
                status = pod.get("status", {})

                filtered_pod = {
                    "name": metadata.get("name"),
                    "status": status.get("phase"),
                    "namespace": metadata.get("namespace"),
                    "created": metadata.get("creationTimestamp")
                }

                # Add restart count if available
                container_statuses = status.get("containerStatuses", [])
                if container_statuses:
                    restart_count = sum(cs.get("restartCount", 0) for cs in container_statuses)
                    filtered_pod["restarts"] = restart_count

                filtered_pods.append(filtered_pod)

            return {
                "success": True,
                "namespace": namespace,
                "pod_count": len(filtered_pods),
                "pods": filtered_pods
            }

        except json.JSONDecodeError as e:
            return {"success": False, "error": f"JSON decode error: {str(e)}"}

    def get_services(self, namespace: str = "default") -> Dict:
        """Get services with minimal token-efficient response."""
        try:
            result = self.run_kubectl([
                "get", "services",
                "-n", namespace,
                "-o", "json"
            ])

            if not result["success"]:
                return result

            services_data = json.loads(result["stdout"])
            filtered_services = []

            for service in services_data.get("items", []):
                metadata = service.get("metadata", {})
                spec = service.get("spec", {})

                filtered_service = {
                    "name": metadata.get("name"),
                    "type": spec.get("type"),
                    "namespace": metadata.get("namespace"),
                    "cluster_ip": spec.get("clusterIP")
                }

                # Add ports information
                ports = spec.get("ports", [])
                if ports:
                    filtered_service["ports"] = [
                        {
                            "port": p.get("port"),
                            "target_port": p.get("targetPort"),
                            "protocol": p.get("protocol")
                        }
                        for p in ports
                    ]

                filtered_services.append(filtered_service)

            return {
                "success": True,
                "namespace": namespace,
                "service_count": len(filtered_services),
                "services": filtered_services
            }

        except json.JSONDecodeError as e:
            return {"success": False, "error": f"JSON decode error: {str(e)}"}

    def get_deployments(self, namespace: str = "default") -> Dict:
        """Get deployments with minimal token-efficient response."""
        try:
            result = self.run_kubectl([
                "get", "deployments",
                "-n", namespace,
                "-o", "json"
            ])

            if not result["success"]:
                return result

            deployments_data = json.loads(result["stdout"])
            filtered_deployments = []

            for deployment in deployments_data.get("items", []):
                metadata = deployment.get("metadata", {})
                spec = deployment.get("spec", {})
                status = deployment.get("status", {})

                filtered_deployment = {
                    "name": metadata.get("name"),
                    "namespace": metadata.get("namespace"),
                    "desired_replicas": spec.get("replicas", 1),
                    "available_replicas": status.get("availableReplicas", 0),
                    "ready_replicas": status.get("readyReplicas", 0)
                }

                filtered_deployments.append(filtered_deployment)

            return {
                "success": True,
                "namespace": namespace,
                "deployment_count": len(filtered_deployments),
                "deployments": filtered_deployments
            }

        except json.JSONDecodeError as e:
            return {"success": False, "error": f"JSON decode error: {str(e)}"}


def main():
    """Main function demonstrating token-efficient Kubernetes operations."""
    if len(sys.argv) < 2:
        print("Usage: k8s_example.py <operation> [args...]")
        print("Operations: get_pods [namespace], get_services [namespace], get_deployments [namespace]")
        return 1

    operation = sys.argv[1]

    # Get kubeconfig from environment or default
    kubeconfig = os.environ.get("KUBECONFIG")
    k8s = KubernetesWrapper(kubeconfig)

    if operation == "get_pods":
        namespace = sys.argv[2] if len(sys.argv) > 2 else "default"
        result = k8s.get_pods(namespace)
        print(json.dumps(result, indent=2))

    elif operation == "get_services":
        namespace = sys.argv[2] if len(sys.argv) > 2 else "default"
        result = k8s.get_services(namespace)
        print(json.dumps(result, indent=2))

    elif operation == "get_deployments":
        namespace = sys.argv[2] if len(sys.argv) > 2 else "default"
        result = k8s.get_deployments(namespace)
        print(json.dumps(result, indent=2))

    else:
        print(f"Unknown operation: {operation}", file=sys.stderr)
        print("Usage: k8s_example.py <operation> [args...]")
        print("Operations: get_pods [namespace], get_services [namespace], get_deployments [namespace]")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())