---
name: postgres-k8s-setup
description: Deploy PostgreSQL on Kubernetes with initial schema
---

# Postgres K8s Setup

## When to Use
Use this skill to set up PostgreSQL database for LearnFlow app.

## Instructions
1. Run `deploy.sh` to install PostgreSQL using Helm
2. Run `verify.py` to test database connection
3. Run `migrate.py` to apply schema migrations

## Validation Checklist
- [ ] Database is accessible
- [ ] Required tables are created
- [ ] Connection test passes
- [ ] Initial schema loaded

For detailed configuration, see REFERENCE.md.