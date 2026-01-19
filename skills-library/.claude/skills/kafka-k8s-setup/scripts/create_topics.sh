#!/bin/bash

# Kafka K8s Setup - Topic Creation Script
# Creates required Kafka topics after deployment

set -euo pipefail

echo "Creating Kafka topics..."

# Wait a bit to ensure Kafka is ready
sleep 10

# Get Kafka pod name
KAFKA_POD=$(kubectl get pods -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$KAFKA_POD" ]; then
    echo "ERROR: Could not find Kafka pod"
    exit 1
fi

echo "Found Kafka pod: $KAFKA_POD"

# Define topics to create
TOPICS=("learning.events" "code.changes" "exercise.submissions" "user.activities")

# Create each topic
for topic in "${TOPICS[@]}"; do
    echo "Creating topic: $topic"

    # Execute kafka-topics command inside the Kafka pod
    kubectl exec "$KAFKA_POD" -- \
        kafka-topics.sh \
        --create \
        --topic "$topic" \
        --bootstrap-server localhost:9092 \
        --partitions 1 \
        --replication-factor 1

    if [ $? -eq 0 ]; then
        echo "✓ Successfully created topic: $topic"
    else
        echo "✗ Failed to create topic: $topic"
    fi
done

# List created topics to verify
echo "Verifying created topics..."
kubectl exec "$KAFKA_POD" -- \
    kafka-topics.sh \
    --list \
    --bootstrap-server localhost:9092

echo "Topic creation process completed."