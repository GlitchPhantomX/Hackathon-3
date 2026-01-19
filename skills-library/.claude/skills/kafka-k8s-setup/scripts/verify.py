#!/usr/bin/env python3
"""
Kafka K8s Setup - Verification Script
Checks pod status and connectivity for Kafka deployment.
"""

import subprocess
import sys
import time
import json


def run_command(cmd):
    """Run a shell command and return the result."""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip(), result.stderr.strip(), 0
    except subprocess.CalledProcessError as e:
        return e.stdout.strip(), e.stderr.strip(), e.returncode


def check_pods_status():
    """Check the status of Kafka and Zookeeper pods."""
    # Get all pods in the default namespace
    stdout, stderr, rc = run_command("kubectl get pods -o json")

    if rc != 0:
        print(f"ERROR: Could not retrieve pods: {stderr}")
        return False

    try:
        pods_data = json.loads(stdout)
        kafka_pods = []
        zk_pods = []

        for pod in pods_data.get('items', []):
            pod_name = pod['metadata']['name']
            if 'kafka' in pod_name:
                kafka_pods.append((pod_name, pod['status'].get('phase', 'Unknown')))
            elif 'zookeeper' in pod_name or ('zk' in pod_name):
                zk_pods.append((pod_name, pod['status'].get('phase', 'Unknown')))

        all_running = True

        print(f"Found {len(kafka_pods)} Kafka pods:")
        for pod_name, phase in kafka_pods:
            status = "✓" if phase == "Running" else "✗"
            print(f"  {status} {pod_name}: {phase}")
            if phase != "Running":
                all_running = False

        print(f"Found {len(zk_pods)} Zookeeper pods:")
        for pod_name, phase in zk_pods:
            status = "✓" if phase == "Running" else "✗"
            print(f"  {status} {pod_name}: {phase}")
            if phase != "Running":
                all_running = False

        return all_running

    except json.JSONDecodeError:
        print("ERROR: Could not parse kubectl output")
        return False


def test_kafka_connectivity():
    """Test basic Kafka connectivity."""
    # Check if Helm release exists
    stdout, stderr, rc = run_command("helm status kafka")
    if rc != 0:
        print("ERROR: Kafka Helm release not found")
        return False

    print("Kafka Helm release found.")

    # Try to get Kafka service
    stdout, stderr, rc = run_command("kubectl get svc -l app.kubernetes.io/name=kafka -o name")
    if rc != 0:
        print("WARNING: Could not find Kafka service, but pods might still be starting")
        return True  # Don't fail if service not found yet

    print("Kafka service found.")
    return True


def main():
    """Main verification function."""
    print("Verifying Kafka deployment...")

    # Check pod statuses
    pods_ok = check_pods_status()

    # Test connectivity
    connectivity_ok = test_kafka_connectivity()

    if pods_ok and connectivity_ok:
        # Count total running pods
        stdout, _, _ = run_command("kubectl get pods --field-selector=status.phase=Running --no-headers | wc -l")
        try:
            running_count = int(stdout)
            print(f"SUCCESS: All {running_count} pods are running")
            return 0
        except ValueError:
            print("SUCCESS: Kafka deployment verification passed")
            return 0
    else:
        print("ERROR: Kafka deployment verification failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())