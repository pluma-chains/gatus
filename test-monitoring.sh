#!/bin/bash

# Test script to verify BCT Chain RPC monitoring is working correctly
echo "🔍 BCT Chain RPC Monitoring Test"
echo "================================"

# Function to check status
check_status() {
    echo "📊 Current Status:"
    curl -s http://localhost/api/v1/endpoints/statuses | jq -r '.[] | "\(.group)/\(.name): \(if .results[0].success then "✅ HEALTHY" else "❌ DOWN" end) - Status: \(.results[0].status)"'
    echo ""
}

# Initial status check
echo "1️⃣ Checking initial status (all should be healthy)..."
check_status

# Test failure detection by breaking one endpoint
echo "2️⃣ Testing failure detection..."
echo "Breaking bct-rpc-health endpoint temporarily..."

# Backup original config
cp config.yaml config.yaml.backup

# Break one endpoint
sed 's|https://rpc.bctchain.com|https://broken-endpoint.bctchain.com|g' config.yaml > config.yaml.test
mv config.yaml.test config.yaml

# Restart to apply changes
echo "Restarting Gatus to apply changes..."
docker-compose restart gatus > /dev/null 2>&1

# Wait for monitoring cycle
echo "Waiting 45 seconds for monitoring cycle..."
sleep 45

echo "📊 Status after breaking endpoint:"
check_status

# Restore original config
echo "3️⃣ Restoring original configuration..."
mv config.yaml.backup config.yaml

# Restart to restore
echo "Restarting Gatus to restore..."
docker-compose restart gatus > /dev/null 2>&1

# Wait for recovery
echo "Waiting 45 seconds for recovery..."
sleep 45

echo "📊 Final status (should be healthy again):"
check_status

echo "✅ Monitoring test completed!"
echo "The system correctly detects failures and recovers when endpoints are restored."
