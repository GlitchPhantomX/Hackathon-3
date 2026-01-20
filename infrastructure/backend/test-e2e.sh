#!/bin/bash
# End-to-end test for all services

set -e

echo "=== LearnFlow Backend E2E Tests ==="

# Port-forward triage
kubectl port-forward svc/triage-service 8000:80 &
PF_PID=$!
sleep 3

# Test 1: Concepts query
echo "Test 1: Concept explanation..."
response=$(curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{"student_id":"test","session_id":"e2e-1","query":"Explain Python variables"}' 2>/dev/null)

if [[ "$response" == *"concepts"* ]] || [[ "$response" == *"concepts-service"* ]]; then
  echo "✅ Routed to concepts"
else
  echo "❌ Failed to route to concepts: $response"
fi

# Test 2: Debug query
echo "Test 2: Debug assistance..."
response=$(curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{"student_id":"test","session_id":"e2e-2","query":"Fix my error: NameError"}' 2>/dev/null)

if [[ "$response" == *"debug"* ]] || [[ "$response" == *"debug-service"* ]]; then
  echo "✅ Routed to debug"
else
  echo "❌ Failed to route to debug: $response"
fi

# Test 3: Exercise query
echo "Test 3: Exercise generation..."
response=$(curl -X POST http://localhost:8000/api/triage \
  -H "Content-Type: application/json" \
  -d '{"student_id":"test","session_id":"e2e-3","query":"Give me practice exercises"}' 2>/dev/null)

if [[ "$response" == *"exercise"* ]] || [[ "$response" == *"exercise-service"* ]]; then
  echo "✅ Routed to exercise"
else
  echo "❌ Failed to route to exercise: $response"
fi

# Test 4: Health check
echo "Test 4: Health check..."
health_response=$(curl -s http://localhost:8000/health)
if [[ "$health_response" == *"healthy"* ]]; then
  echo "✅ Health check passed"
else
  echo "❌ Health check failed: $health_response"
fi

# Cleanup
kill $PF_PID

echo ""
echo "=== E2E Tests Complete ==="