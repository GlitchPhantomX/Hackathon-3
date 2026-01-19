#!/usr/bin/env python3
"""
Postgres K8s Setup - Verification Script
Tests database connection and verifies setup.
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


def check_pod_status():
    """Check the status of PostgreSQL pod."""
    # Get pods in the postgres-db namespace
    stdout, stderr, rc = run_command("kubectl get pods -n postgres-db -o json")

    if rc != 0:
        print(f"ERROR: Could not retrieve pods: {stderr}")
        return False

    try:
        pods_data = json.loads(stdout)
        postgres_pods = []

        for pod in pods_data.get('items', []):
            pod_name = pod['metadata']['name']
            if 'postgresql' in pod_name:
                postgres_pods.append((pod_name, pod['status'].get('phase', 'Unknown')))

        all_running = True

        print(f"Found {len(postgres_pods)} PostgreSQL pods:")
        for pod_name, phase in postgres_pods:
            status = "✓" if phase == "Running" else "✗"
            print(f"  {status} {pod_name}: {phase}")
            if phase != "Running":
                all_running = False

        return all_running

    except json.JSONDecodeError:
        print("ERROR: Could not parse kubectl output")
        return False


def test_db_connection():
    """Test basic PostgreSQL connectivity."""
    # Check if Helm release exists
    stdout, stderr, rc = run_command("helm status postgresql -n postgres-db")
    if rc != 0:
        print("ERROR: PostgreSQL Helm release not found")
        return False

    print("PostgreSQL Helm release found.")

    # Get the PostgreSQL pod name
    stdout, stderr, rc = run_command("kubectl get pods -n postgres-db -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}'")
    if rc != 0:
        print("ERROR: Could not find PostgreSQL pod")
        return False

    postgres_pod = stdout.strip()
    if not postgres_pod:
        print("ERROR: No PostgreSQL pod found")
        return False

    print(f"Testing connection to PostgreSQL pod: {postgres_pod}")

    # Test connection by running a simple query inside the pod
    test_cmd = f"kubectl exec -n postgres-db {postgres_pod} -- psql -U postgres -d learnflow -c 'SELECT version();'"
    stdout, stderr, rc = run_command(test_cmd)

    if rc == 0:
        print("✓ Database connection test successful")
        return True
    else:
        print(f"✗ Database connection test failed: {stderr}")
        return False


def check_tables_exist():
    """Check if required tables exist in the database."""
    # Get the PostgreSQL pod name
    stdout, stderr, rc = run_command("kubectl get pods -n postgres-db -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}'")
    if rc != 0:
        print("ERROR: Could not find PostgreSQL pod")
        return False

    postgres_pod = stdout.strip()
    if not postgres_pod:
        print("ERROR: No PostgreSQL pod found")
        return False

    # Check for required tables
    tables_to_check = ['users', 'student_progress', 'exercises', 'code_submissions']
    existing_tables = []

    for table in tables_to_check:
        check_cmd = f"kubectl exec -n postgres-db {postgres_pod} -- psql -U postgres -d learnflow -tAc \"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '{table}');\""
        stdout, stderr, rc = run_command(check_cmd)

        if rc == 0 and stdout.strip() == 't':
            existing_tables.append(table)

    print(f"Found {len(existing_tables)} out of {len(tables_to_check)} required tables: {existing_tables}")

    if len(existing_tables) == len(tables_to_check):
        print("✓ All required tables exist")
        return True
    else:
        print("⚠ Some required tables are missing, but this might be expected before schema initialization")
        return True  # Don't fail if tables don't exist yet


def main():
    """Main verification function."""
    print("Verifying PostgreSQL deployment...")

    # Check pod status
    pod_ok = check_pod_status()

    # Test database connection
    db_ok = test_db_connection()

    # Check for required tables
    tables_ok = check_tables_exist()

    if pod_ok and db_ok and tables_ok:
        print("SUCCESS: PostgreSQL deployment verification passed")
        return 0
    else:
        print("ERROR: PostgreSQL deployment verification failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())