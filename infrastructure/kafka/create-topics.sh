#!/bin/bash

# Kafka Topic Creation Script for LearnFlow
# Creates all 9 required Kafka topics with appropriate configuration

set -e  # Exit on any error

echo "🚀 Creating LearnFlow Kafka Topics..."

# Get Kafka pod name dynamically
KAFKA_POD=$(kubectl get pods -n default -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || kubectl get pods -n default -l app=kafka -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$KAFKA_POD" ]; then
    echo "❌ Could not find Kafka pod"
    echo "💡 Make sure Kafka is deployed and running before executing this script"
    exit 1
fi

echo "✅ Found Kafka pod: $KAFKA_POD"

# Wait for Kafka to be ready
echo "⏳ Waiting for Kafka broker to be ready..."
kubectl exec -n default "$KAFKA_POD" -- timeout 30s bash -c 'until kafka-broker-api-versions.sh --bootstrap-server localhost:9092 > /dev/null 2>&1; do sleep 2; done' || {
    echo "❌ Kafka broker is not ready after waiting"
    exit 1
}

echo "✅ Kafka broker is ready, creating topics..."

# Function to create a topic with error handling
create_topic() {
    local topic_name=$1
    local partitions=$2
    local retention_ms=$3

    echo "📍 Creating topic: $topic_name ($partitions partitions, retention: $((retention_ms/86400000)) days)"

    # Create topic with specified configuration
    kubectl exec -n default "$KAFKA_POD" -- kafka-topics.sh \
        --create \
        --if-not-exists \
        --bootstrap-server localhost:9092 \
        --replication-factor 1 \
        --partitions "$partitions" \
        --topic "$topic_name" \
        --config retention.ms="$retention_ms" 2>/dev/null || {
            # Check if topic already exists
            if kubectl exec -n default "$KAFKA_POD" -- kafka-topics.sh --list --bootstrap-server localhost:9092 | grep -q "^$topic_name$"; then
                echo "⚠️  Topic $topic_name already exists, skipping..."
            else
                echo "❌ Failed to create topic: $topic_name"
                return 1
            fi
        }

    echo "✅ Topic $topic_name created successfully"
}

# Create learning service topics (3 partitions, 7-day retention = 604800000 ms)
create_topic "learning.query" 3 604800000
create_topic "learning.response" 3 604800000

# Create code execution service topics (3 partitions, 3-day retention = 259200000 ms)
create_topic "code.execution.request" 3 259200000
create_topic "code.execution.result" 3 259200000

# Create exercise service topics (2 partitions, 30-day retention = 2592000000 ms)
create_topic "exercise.assigned" 2 2592000000
create_topic "exercise.submitted" 2 2592000000
create_topic "exercise.graded" 2 2592000000

# Create struggle detection topic (2 partitions, 7-day retention = 604800000 ms)
create_topic "struggle.detected" 2 604800000

# Create progress tracking topic (2 partitions, 30-day retention = 2592000000 ms)
create_topic "progress.updated" 2 2592000000

echo ""
echo "📋 Listing all created topics to verify:"
kubectl exec -n default "$KAFKA_POD" -- kafka-topics.sh --list --bootstrap-server localhost:9092

echo ""
echo "🎉 All 9 LearnFlow Kafka topics created successfully!"
echo "✅ Topics created: learning.query, learning.response, code.execution.request, code.execution.result, exercise.assigned, exercise.submitted, exercise.graded, struggle.detected, progress.updated"

exit 0