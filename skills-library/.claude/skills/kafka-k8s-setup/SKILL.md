---
name: kafka-k8s-setup
description: Deploy Apache Kafka on Kubernetes with Zookeeper
---

# Kafka K8s Setup

## When to Use
Use this skill to set up Apache Kafka on Kubernetes for event-driven microservices.

## Instructions
1. Run `deploy.sh` to install Kafka using Helm
2. Run `verify.py` to check pod status and connectivity
3. Run `create_topics.sh` to create required Kafka topics

## Validation Checklist
- [ ] All Kafka pods are Running
- [ ] Zookeeper pods are Running
- [ ] Can create and list Kafka topics
- [ ] Connectivity test passes

For detailed configuration, see REFERENCE.md.