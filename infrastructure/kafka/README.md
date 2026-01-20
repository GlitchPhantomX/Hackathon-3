# LearnFlow Kafka Setup

This document describes the Kafka setup for the LearnFlow application, including deployment, configuration, and usage instructions.

## 🚀 Quick Start

### Deploy Kafka
```bash
# Add Bitnami Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create namespace
kubectl create namespace kafka

# Install Kafka with custom values
helm install kafka bitnami/kafka \
  --namespace kafka \
  --values values.yaml \
  --wait --timeout 10m
```

### Create Topics
```bash
# Execute topic creation script
./create-topics.sh
```

### Verify Deployment
```bash
# Run verification script
./verify-kafka.sh
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Services      │    │     Kafka        │    │   Consumers     │
│                 │◄──►│   (Brokers)      │◄──►│                 │
│ (Producers)     │    │                  │    │ (Applications)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                            ▲
                            │
                    ┌───────────────┐
                    │   Zookeeper   │
                    │               │
                    └───────────────┘
```

Kafka acts as the central event streaming platform for LearnFlow services, with Zookeeper providing coordination services. Producers publish events to topics, and consumers subscribe to process them asynchronously.

## 📚 Topics Overview

LearnFlow uses 9 distinct Kafka topics for different services:

| Topic Name | Purpose | Partitions | Retention |
|------------|---------|------------|-----------|
| `learning.query` | Learning service queries | 3 | 7 days |
| `learning.response` | Learning service responses | 3 | 7 days |
| `code.execution.request` | Code execution requests | 3 | 3 days |
| `code.execution.result` | Code execution results | 3 | 3 days |
| `exercise.assigned` | Exercise assignment notifications | 2 | 30 days |
| `exercise.submitted` | Exercise submission notifications | 2 | 30 days |
| `exercise.graded` | Exercise grading results | 2 | 30 days |
| `struggle.detected` | Student struggle detection alerts | 2 | 7 days |
| `progress.updated` | Student progress updates | 2 | 30 days |

## 🔌 Connection Information

### For Applications
```bash
# Kafka Bootstrap Server
kafka:9092

# Example connection string for services
kafka.kafka.svc.cluster.local:9092
```

### From Outside the Cluster
```bash
# Port forward to access locally
kubectl port-forward -n kafka svc/kafka 9092:9092
```

## 🧪 Testing

### Produce Test Message
```bash
# Example: Send a learning query
kubectl exec -it -n kafka <kafka-pod-name> -- kafka-console-producer.sh \
  --bootstrap-server localhost:9092 \
  --topic learning.query
```

### Consume Test Messages
```bash
# Example: Consume learning queries
kubectl exec -it -n kafka <kafka-pod-name> -- kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic learning.query \
  --from-beginning
```

## 🛠️ Troubleshooting

### Common Issues

1. **Kafka pods stuck in Pending state**
   - Check if there are enough nodes and resources available
   - Verify PersistentVolume availability
   - Check storage class configuration

2. **Topics not being created**
   - Ensure Kafka is fully ready before running topic creation script
   - Check Kafka pod logs: `kubectl logs -n kafka <kafka-pod>`
   - Verify topic creation script permissions

3. **Connection timeouts**
   - Verify service is accessible within the cluster
   - Check network policies if enabled
   - Ensure DNS resolution works: `nslookup kafka.kafka.svc.cluster.local`

4. **Zookeeper issues**
   - Check Zookeeper pod status: `kubectl get pods -n kafka -l app.kubernetes.io/name=zookeeper`
   - Review Zookeeper logs if connection problems occur

### Useful Commands

```bash
# Check all Kafka-related pods
kubectl get pods -n kafka -l app.kubernetes.io/name=kafka

# Check all Kafka services
kubectl get svc -n kafka -l app.kubernetes.io/name=kafka

# View Kafka logs
kubectl logs -n kafka -l app.kubernetes.io/name=kafka

# List all topics
kubectl exec -n kafka <kafka-pod> -- kafka-topics.sh --list --bootstrap-server localhost:9092

# Describe a specific topic
kubectl exec -n kafka <kafka-pod> -- kafka-topics.sh --describe --topic learning.query --bootstrap-server localhost:9092
```

## 📋 Maintenance

### Monitoring Topic Health
Regularly monitor topic lag and consumer group status:
```bash
# Check consumer groups
kubectl exec -n kafka <kafka-pod> -- kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# Describe a consumer group
kubectl exec -n kafka <kafka-pod> -- kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group <consumer-group-name>
```

### Scaling Considerations
- Increase partitions for high-throughput topics
- Adjust resource limits based on message volume
- Monitor disk usage and retention policies