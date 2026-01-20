#!/bin/bash

# Kafka Verification Script for LearnFlow
# Comprehensive verification of Kafka deployment health

set -e  # Exit on any error

echo "🔍 Verifying LearnFlow Kafka Deployment..."
echo ""

# Initialize counters
total_checks=0
passed_checks=0

# Function to run a check
run_check() {
    local description=$1
    local command=$2
    ((total_checks++))

    if eval "$command" &> /dev/null; then
        echo "✅ $description"
        ((passed_checks++))
    else
        echo "❌ $description"
    fi
}

# Check 1: Verify Kafka namespace exists
echo "📍 Checking Kafka namespace..."
run_check "Kafka namespace exists" "kubectl get namespace default &> /dev/null"

# Check 2: Verify Kafka pods are Running
echo ""
echo "📍 Checking Kafka pods status..."
KAFKA_PODS=$(kubectl get pods -n default -l app.kubernetes.io/name=kafka,app.kubernetes.io/instance=kafka 2>/dev/null || kubectl get pods -n default -l app=kafka 2>/dev/null || echo "")
if [ -n "$KAFKA_PODS" ]; then
    POD_STATUS=$(echo "$KAFKA_PODS" | awk 'NR>1 {print $3}' | uniq)
    if [ "$POD_STATUS" = "Running" ]; then
        echo "✅ Kafka pods are Running"
        ((passed_checks++))
        ((total_checks++))
    else
        echo "❌ Kafka pods are not Running (status: $POD_STATUS)"
        ((total_checks++))
    fi
else
    echo "❌ No Kafka pods found"
    ((total_checks++))
fi

# Check 3: Verify Zookeeper pods are Running
echo ""
echo "📍 Checking Zookeeper pods status..."
ZOOKEEPER_PODS=$(kubectl get pods -n default -l app.kubernetes.io/name=zookeeper,app.kubernetes.io/instance=kafka-zookeeper 2>/dev/null || kubectl get pods -n default -l app=zookeeper 2>/dev/null || echo "")
if [ -n "$ZOOKEEPER_PODS" ]; then
    ZK_POD_STATUS=$(echo "$ZOOKEEPER_PODS" | awk 'NR>1 {print $3}' | uniq)
    if [ "$ZK_POD_STATUS" = "Running" ]; then
        echo "✅ Zookeeper pods are Running"
        ((passed_checks++))
        ((total_checks++))
    else
        echo "❌ Zookeeper pods are not Running (status: $ZK_POD_STATUS)"
        ((total_checks++))
    fi
else
    echo "❌ No Zookeeper pods found"
    ((total_checks++))
fi

# Check 4: Verify Kafka service exists and has ClusterIP
echo ""
echo "📍 Checking Kafka service..."
SERVICE_EXISTS=$(kubectl get svc -n default -l app.kubernetes.io/name=kafka 2>/dev/null || kubectl get svc -n default -l app=kafka 2>/dev/null || echo "")
if [ -n "$SERVICE_EXISTS" ]; then
    CLUSTER_IP=$(kubectl get svc -n default -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].spec.clusterIP}' 2>/dev/null || kubectl get svc -n default -l app=kafka -o jsonpath='{.items[0].spec.clusterIP}' 2>/dev/null)
    if [ -n "$CLUSTER_IP" ] && [ "$CLUSTER_IP" != "<none>" ]; then
        echo "✅ Kafka service exists with ClusterIP: $CLUSTER_IP"
        ((passed_checks++))
        ((total_checks++))
    else
        echo "❌ Kafka service exists but has no ClusterIP"
        ((total_checks++))
    fi
else
    echo "❌ Kafka service not found"
    ((total_checks++))
fi

# Check 5: Test Kafka connectivity (if pods are running)
echo ""
echo "📍 Testing Kafka connectivity..."
KAFKA_POD=$(kubectl get pods -n default -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || kubectl get pods -n default -l app=kafka -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$KAFKA_POD" ]; then
    if kubectl exec -n default "$KAFKA_POD" -- timeout 10s bash -c 'kafka-broker-api-versions.sh --bootstrap-server localhost:9092' &> /dev/null; then
        echo "✅ Kafka connectivity test successful"
        ((passed_checks++))
        ((total_checks++))
    else
        echo "❌ Kafka connectivity test failed"
        ((total_checks++))
    fi
else
    echo "❌ Cannot test Kafka connectivity - no Kafka pod found"
    ((total_checks++))
fi

# Check 6: Verify all 9 topics exist
echo ""
echo "📍 Verifying all 9 LearnFlow topics exist..."
EXPECTED_TOPICS=(
    "learning.query"
    "learning.response"
    "code.execution.request"
    "code.execution.result"
    "exercise.assigned"
    "exercise.submitted"
    "exercise.graded"
    "struggle.detected"
    "progress.updated"
)

if [ -n "$KAFKA_POD" ]; then
    ACTUAL_TOPICS=$(kubectl exec -n default "$KAFKA_POD" -- kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | tr '\n' ' ')

    MISSING_TOPICS=()
    for topic in "${EXPECTED_TOPICS[@]}"; do
        if [[ ! "$ACTUAL_TOPICS" =~ (^|[[:space:]])"$topic"($|[[:space:]]) ]]; then
            MISSING_TOPICS+=("$topic")
        fi
    done

    if [ ${#MISSING_TOPICS[@]} -eq 0 ]; then
        echo "✅ All 9 LearnFlow topics exist"
        ((passed_checks++))
        ((total_checks++))
    else
        echo "❌ Missing topics: ${MISSING_TOPICS[*]}"
        ((total_checks++))
    fi
else
    echo "❌ Cannot verify topics - no Kafka pod found"
    ((total_checks++))
fi

# Summary
echo ""
echo "📊 Verification Summary:"
echo "Total checks: $total_checks"
echo "Passed: $passed_checks"
echo "Failed: $((total_checks - passed_checks))"

if [ $passed_checks -eq $total_checks ]; then
    echo ""
    echo "🎉 All Kafka verification checks PASSED!"
    echo "✅ LearnFlow Kafka deployment is healthy and operational."
    exit 0
else
    echo ""
    echo "❌ Some Kafka verification checks FAILED!"
    echo "⚠️  LearnFlow Kafka deployment has issues that need to be resolved."
    exit 1
fi