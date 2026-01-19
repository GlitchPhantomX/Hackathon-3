#!/usr/bin/env python3
"""
Postgres K8s Setup - Migration Script
Applies database schema migrations.
"""

import subprocess
import sys
import os
import tempfile


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


def get_postgres_pod():
    """Get the PostgreSQL pod name."""
    stdout, stderr, rc = run_command("kubectl get pods -n postgres-db -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}'")
    if rc != 0:
        print("ERROR: Could not find PostgreSQL pod")
        return None

    postgres_pod = stdout.strip()
    if not postgres_pod:
        print("ERROR: No PostgreSQL pod found")
        return None

    return postgres_pod


def apply_schema_sql(pod_name, sql_content):
    """Apply SQL content to the database."""
    # Create a temporary file with the SQL content
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', delete=False) as temp_file:
        temp_file.write(sql_content)
        temp_file_path = temp_file.name

    try:
        # Copy the SQL file to the pod
        copy_cmd = f"kubectl cp {temp_file_path} -n postgres-db {pod_name}:/tmp/schema.sql"
        stdout, stderr, rc = run_command(copy_cmd)
        if rc != 0:
            print(f"ERROR: Could not copy schema file to pod: {stderr}")
            return False

        # Execute the SQL file in the database
        exec_cmd = f"kubectl exec -n postgres-db {pod_name} -- psql -U postgres -d learnflow -f /tmp/schema.sql"
        stdout, stderr, rc = run_command(exec_cmd)

        if rc == 0:
            print("✓ Schema applied successfully")
            return True
        else:
            print(f"✗ Schema application failed: {stderr}")
            return False

    finally:
        # Clean up the temporary file
        os.unlink(temp_file_path)


def main():
    """Main migration function."""
    print("Applying database migrations...")

    # Get the PostgreSQL pod name
    postgres_pod = get_postgres_pod()
    if not postgres_pod:
        return 1

    print(f"Targeting PostgreSQL pod: {postgres_pod}")

    # Read the init schema SQL file
    try:
        with open('init_schema.sql', 'r') as f:
            schema_sql = f.read()
    except FileNotFoundError:
        print("ERROR: init_schema.sql file not found in current directory")
        # Try to find it in the scripts directory
        script_dir = os.path.dirname(os.path.abspath(__file__))
        schema_path = os.path.join(script_dir, 'init_schema.sql')
        try:
            with open(schema_path, 'r') as f:
                schema_sql = f.read()
        except FileNotFoundError:
            print(f"ERROR: init_schema.sql file not found at {schema_path}")
            return 1

    # Apply the schema
    success = apply_schema_sql(postgres_pod, schema_sql)
    if not success:
        return 1

    # Verify tables were created
    print("Verifying tables...")
    verify_cmd = f"kubectl exec -n postgres-db {postgres_pod} -- psql -U postgres -d learnflow -c \"\\dt\""
    stdout, stderr, rc = run_command(verify_cmd)

    if rc == 0:
        print("✓ Database migration completed successfully")
        print("Tables created:")
        print(stdout)
        return 0
    else:
        print(f"✗ Migration verification failed: {stderr}")
        return 1


if __name__ == "__main__":
    sys.exit(main())