# Kafka K8s Setup - Detailed Documentation

## Overview
The Kafka K8s Setup skill automates the deployment of Apache Kafka on Kubernetes using the Bitnami Helm chart. It handles the complete setup including Zookeeper, broker configuration, and topic creation.

## Architecture
- Deploys Kafka brokers with configurable replica count
- Sets up Zookeeper ensemble for coordination
- Configures persistent storage for data durability
- Exposes services for client connectivity

## Configuration Parameters
- `replicaCount`: Number of Kafka broker replicas (default: 1)
- `zookeeper.replicaCount`: Number of Zookeeper replicas (default: 1)
- `persistence.enabled`: Enable/disable persistent storage
- `resources.limits`: CPU and memory limits for containers
- `service.type`: Service type (ClusterIP, NodePort, LoadBalancer)

## Deployment Process
1. Adds Bitnami Helm repository
2. Updates Helm repositories
3. Installs Kafka chart with specified configuration
4. Waits for all pods to reach Running state
5. Verifies service connectivity

## Topic Management
- Creates topics with specified partition count
- Configures replication factor for fault tolerance
- Sets retention policies for message persistence
- Supports topic-level configuration overrides

## Security Considerations
- Network policies restrict access to Kafka cluster
- TLS encryption for client-broker communication
- Authentication mechanisms (SASL/SCRAM, Kerberos)
- RBAC for Kubernetes resource access

## Monitoring & Logging
- Prometheus metrics exposed by Kafka brokers
- Log aggregation via standard Kubernetes logging
- Health checks for automated failure recovery
- Resource utilization monitoring

## Troubleshooting
Common issues and solutions:
- Pod stuck in Pending: Check resource availability
- Connection timeouts: Verify service networking
- Topic creation failures: Check Zookeeper connectivity
- High latency: Review resource allocation
