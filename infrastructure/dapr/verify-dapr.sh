#!/bin/bash

# Dapr Verification Script for LearnFlow
# Comprehensive verification of Dapr installation and components

set -e  # Exit on any error

echo "🔍 Verifying LearnFlow Dapr Installation..."
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

# Check 1: Verify Dapr CLI is installed
echo "📍 Checking Dapr CLI installation..."
if command -v dapr &> /dev/null; then
    echo "✅ Dapr CLI is installed"
    DAPR_VERSION=$(dapr --version 2>/dev/null || echo "unknown")
    echo "   Dapr version: $DAPR_VERSION"
    ((passed_checks++))
    ((total_checks++))
else
    echo "❌ Dapr CLI is not installed"
    ((total_checks++))
fi

# Check 2: Verify Dapr control plane pods are running
echo ""
echo "📍 Checking Dapr control plane pods..."
DAPR_PODS=$(kubectl get pods -n dapr-system 2>/dev/null || echo "")
if [ -n "$DAPR_PODS" ]; then
    # Check each control plane component
    OPERATOR_STATUS=$(kubectl get pods -n dapr-system -l app=dapr-operator -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
    SIDECAR_STATUS=$(kubectl get pods -n dapr-system -l app=dapr-sidecar-injector -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
    PLACEMENT_STATUS=$(kubectl get pods -n dapr-system -l app=dapr-placement-server -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")

    if [ "$OPERATOR_STATUS" = "Running" ]; then
        echo "✅ Dapr operator is Running"
        ((passed_checks++))
        ((total_checks++))
    else
        echo "❌ Dapr operator is not Running (status: $OPERATOR_STATUS)"
        ((total_checks++))
    fi

    if [ "$SIDECAR_STATUS" = "Running" ]; then
        echo "✅ Dapr sidecar injector is Running"
        ((passed_checks++))
        ((total_checks++))
    else
        echo "❌ Dapr sidecar injector is not Running (status: $SIDECAR_STATUS)"
        ((total_checks++))
    fi

    if [ "$PLACEMENT_STATUS" = "Running" ]; then
        echo "✅ Dapr placement server is Running"
        ((passed_checks++))
        ((total_checks++))
    else
        echo "❌ Dapr placement server is not Running (status: $PLACEMENT_STATUS)"
        ((total_checks++))
    fi
else
    echo "❌ Dapr system pods not found"
    ((total_checks++))
    ((total_checks++))
    ((total_checks++))
fi

# Check 3: Verify Dapr components are configured
echo ""
echo "📍 Checking Dapr components configuration..."
COMPONENTS_COUNT=$(kubectl get components -A --no-headers 2>/dev/null | wc -l || echo "0")
if [ "$COMPONENTS_COUNT" -ge 3 ]; then
    echo "✅ All 3 Dapr components are configured ($COMPONENTS_COUNT found)"
    ((passed_checks++))
    ((total_checks++))

    # List the components
    echo "   Components found:"
    kubectl get components -A --no-headers 2>/dev/null | while read -r line; do
        echo "   - $(echo $line | awk '{print $2}') in namespace $(echo $line | awk '{print $1}')"
    done
else
    echo "❌ Only $COMPONENTS_COUNT Dapr components found (expected at least 3)"
    ((total_checks++))
fi

# Check 4: Verify Dapr status
echo ""
echo "📍 Checking Dapr status..."
if dapr status -k &> /dev/null; then
    echo "✅ Dapr status check successful"
    ((passed_checks++))
    ((total_checks++))
else
    echo "❌ Dapr status check failed"
    ((total_checks++))
fi

# Summary
echo ""
echo "📊 Dapr Verification Summary:"
echo "Total checks: $total_checks"
echo "Passed: $passed_checks"
echo "Failed: $((total_checks - passed_checks))"

if [ $passed_checks -eq $total_checks ]; then
    echo ""
    echo "🎉 All Dapr verification checks PASSED!"
    echo "✅ LearnFlow Dapr installation is healthy and operational."
    exit 0
else
    echo ""
    echo "❌ Some Dapr verification checks FAILED!"
    echo "⚠️  LearnFlow Dapr installation has issues that need to be resolved."
    exit 1
fi