# Kafka K8s Setup Reference

## Architecture
The kafka-k8s-setup skill deploys a resilient Kafka cluster with the following components:
- Kafka brokers managed by StatefulSets
- Zookeeper ensemble for coordination
- Service discovery for client connections
- Persistent storage for data durability

## Configuration
Key configuration parameters include:
- Number of broker replicas
- Storage class and size
- Memory and CPU limits
- Network policies
- Security settings

## Networking
The skill sets up proper networking for Kafka:
- Headless services for broker discovery
- External access via LoadBalancer or NodePort
- Internal communication within the cluster

## Security
Security features include:
- TLS encryption for data in transit
- SASL authentication mechanisms
- Network policies for access control
- Pod security policies