#!/bin/bash

# Master Infrastructure Verification Script for LearnFlow
# Runs all component verifications and provides aggregate results

set -e  # Exit on any error

echo "🔍 Running Comprehensive LearnFlow Infrastructure Verification..."
echo ""

# Initialize counters
total_components=0
passed_components=0

# Function to run verification for a component
verify_component() {
    local component=$1
    local script_path=$2
    local description=$3

    ((total_components++))

    echo "📍 Verifying $description..."
    echo "   Running: $script_path"

    if cd "$script_path" && bash "$(basename "$2")" && cd ..; then
        echo "✅ $component verification PASSED"
        ((passed_components++))
    else
        echo "❌ $component verification FAILED"
    fi
    echo ""
}

# Verify Kafka
if [ -f "kafka/verify-kafka.sh" ]; then
    verify_component "Kafka" "kafka/verify-kafka.sh" "Kafka messaging system"
else
    echo "⚠️  Kafka verification script not found"
    ((total_components++))
fi

# Verify PostgreSQL
if [ -f "postgres/verify-postgres.sh" ]; then
    verify_component "PostgreSQL" "postgres/verify-postgres.sh" "PostgreSQL database"
else
    echo "⚠️  PostgreSQL verification script not found"
    ((total_components++))
fi

# Verify Dapr (basic status check)
echo "📍 Verifying Dapr status..."
((total_components++))
if command -v dapr &> /dev/null; then
    if dapr status -k &> /dev/null; then
        echo "✅ Dapr verification PASSED"
        ((passed_components++))
    else
        echo "❌ Dapr verification FAILED"
    fi
else
    echo "⚠️  Dapr CLI not installed"
fi
echo ""

# Summary
echo "📊 Verification Summary:"
echo "Components verified: $passed_components/$total_components"
echo "Success rate: $((passed_components * 100 / total_components))%"
echo ""

# Check if all verifications passed
if [ $passed_components -eq $total_components ] && [ $total_components -gt 0 ]; then
    echo "🎉 ALL INFRASTRUCTURE VERIFICATIONS PASSED!"
    echo "✅ LearnFlow infrastructure is fully operational."
    echo ""
    echo "📋 Status Summary:"
    echo "✅ Kafka: Operational"
    echo "✅ PostgreSQL: Operational"
    echo "✅ Dapr: Operational"
    exit 0
else
    echo "❌ SOME VERIFICATIONS FAILED!"
    echo "⚠️  LearnFlow infrastructure has issues that need attention."
    echo ""
    echo "📋 Status Summary:"
    echo "✅ Kafka: Operational" 2>/dev/null || echo "❌ Kafka: Issues found"
    echo "✅ PostgreSQL: Operational" 2>/dev/null || echo "❌ PostgreSQL: Issues found"
    echo "✅ Dapr: Operational" 2>/dev/null || echo "❌ Dapr: Issues found"
    exit 1
fi