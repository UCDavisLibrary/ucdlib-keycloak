#!/bin/bash

###
# Health check script for Keycloak hot spare deployment
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

source ./config.sh

function check_instance() {
    local port=$1
    local name=$2
    
    echo -n "Checking $name (port $port)... "
    
    if curl -sf "http://localhost:$port/health/ready" > /dev/null 2>&1; then
        echo "✓ HEALTHY"
        return 0
    else
        echo "✗ UNHEALTHY"
        return 1
    fi
}

function check_database() {
    echo -n "Checking database... "
    
    if docker compose exec -T db pg_isready > /dev/null 2>&1; then
        echo "✓ HEALTHY"
        return 0
    else
        echo "✗ UNHEALTHY"
        return 1
    fi
}

echo "=== Keycloak Hot Spare Health Check ==="
echo "Timestamp: $(date)"
echo ""

# Check if hot spare is enabled
if grep -q "ENABLE_HOT_SPARE=true" config.sh; then
    echo "Hot spare is ENABLED"
    echo ""
    
    # Check database first
    check_database
    echo ""
    
    # Check primary instance
    primary_healthy=0
    check_instance $KC_HOST_PORT "Primary Keycloak" || primary_healthy=1
    
    # Check spare instance if it should be running
    spare_healthy=0
    if docker compose ps | grep -q "keycloak-spare"; then
        check_instance $KC_SPARE_HOST_PORT "Spare Keycloak" || spare_healthy=1
    else
        echo "Spare Keycloak (port $KC_SPARE_HOST_PORT)... NOT RUNNING"
        spare_healthy=1
    fi
    
    echo ""
    echo "=== Summary ==="
    if [ $primary_healthy -eq 0 ] && [ $spare_healthy -eq 0 ]; then
        echo "Status: HEALTHY - Both instances running"
        exit 0
    elif [ $primary_healthy -eq 0 ] || [ $spare_healthy -eq 0 ]; then
        echo "Status: DEGRADED - One instance running"
        exit 1
    else
        echo "Status: UNHEALTHY - No instances running"
        exit 2
    fi
else
    echo "Hot spare is DISABLED"
    echo ""
    
    # Check database
    check_database
    echo ""
    
    # Check primary instance only
    if check_instance $KC_HOST_PORT "Primary Keycloak"; then
        echo ""
        echo "=== Summary ==="
        echo "Status: HEALTHY - Single instance running"
        exit 0
    else
        echo ""
        echo "=== Summary ==="
        echo "Status: UNHEALTHY - Primary instance down"
        exit 2
    fi
fi