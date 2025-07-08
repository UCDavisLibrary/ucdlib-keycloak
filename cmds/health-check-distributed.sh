#!/bin/bash

###
# Comprehensive health check for distributed Keycloak deployment
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

source ./config.sh

function usage() {
    echo "Usage: $0 [primary|replica|all|monitor]"
    echo ""
    echo "Commands:"
    echo "  primary  - Check primary instance health"
    echo "  replica  - Check replica instance health"
    echo "  all      - Check both primary and replica"
    echo "  monitor  - Continuous monitoring (Ctrl+C to stop)"
    exit 1
}

function check_primary() {
    echo "=== Primary Instance Health Check ==="
    echo "Timestamp: $(date)"
    echo ""
    
    # Check if primary services are running
    local primary_running=false
    if docker compose -f docker-compose.primary.yaml ps --services --filter "status=running" | grep -q keycloak; then
        primary_running=true
    fi
    
    if [ "$primary_running" = true ]; then
        echo "✓ Primary services are running"
        
        # Check Keycloak health
        echo -n "Keycloak health: "
        if curl -sf "http://localhost:$KC_HOST_PORT/health/ready" > /dev/null 2>&1; then
            echo "✓ HEALTHY"
            primary_kc_healthy=true
        else
            echo "✗ UNHEALTHY"
            primary_kc_healthy=false
        fi
        
        # Check database health
        echo -n "Database health: "
        if docker compose -f docker-compose.primary.yaml exec -T db pg_isready > /dev/null 2>&1; then
            echo "✓ HEALTHY"
            primary_db_healthy=true
        else
            echo "✗ UNHEALTHY"
            primary_db_healthy=false
        fi
        
        # Check for connected replicas
        echo ""
        echo "Connected replicas:"
        docker compose -f docker-compose.primary.yaml exec -T db psql -U $KC_DB_USERNAME -d postgres -c "
        SELECT 
            client_addr as replica_ip,
            state,
            sync_state,
            EXTRACT(EPOCH FROM (now() - backend_start)) as connection_duration_seconds
        FROM pg_stat_replication;
        " 2>/dev/null || echo "No replicas connected"
        
    else
        echo "✗ Primary services are not running"
        primary_kc_healthy=false
        primary_db_healthy=false
    fi
    
    return 0
}

function check_replica() {
    echo "=== Replica Instance Health Check ==="
    echo "Timestamp: $(date)"
    echo ""
    
    # Check if replica services are running
    local replica_running=false
    if docker compose -f docker-compose.replica.yaml ps --services --filter "status=running" | grep -q keycloak-replica; then
        replica_running=true
    fi
    
    if [ "$replica_running" = true ]; then
        echo "✓ Replica services are running"
        
        # Check Keycloak replica health
        echo -n "Keycloak replica health: "
        if curl -sf "http://localhost:3124/health/ready" > /dev/null 2>&1; then
            echo "✓ HEALTHY (read-only)"
            replica_kc_healthy=true
        else
            echo "✗ UNHEALTHY"
            replica_kc_healthy=false
        fi
        
        # Check database replica health
        echo -n "Database replica health: "
        if docker compose -f docker-compose.replica.yaml exec -T db-replica pg_isready > /dev/null 2>&1; then
            echo "✓ HEALTHY"
            replica_db_healthy=true
        else
            echo "✗ UNHEALTHY"
            replica_db_healthy=false
        fi
        
        # Check replication status and lag
        echo ""
        echo "Replication status:"
        if [ -n "$PRIMARY_DB_HOST" ] && nc -z "$PRIMARY_DB_HOST" 5432 2>/dev/null; then
            echo "✓ Connected to primary at $PRIMARY_DB_HOST:5432"
            
            docker compose -f docker-compose.replica.yaml exec -T db-replica psql -U $KC_DB_USERNAME -d postgres -c "
            SELECT 
                CASE 
                    WHEN pg_is_in_recovery() THEN 'Replica (standby)'
                    ELSE 'Primary (ERROR: should be replica!)'
                END as server_type,
                pg_last_wal_receive_lsn() as last_received,
                pg_last_wal_replay_lsn() as last_replayed,
                ROUND(EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp())), 2) as lag_seconds;
            " 2>/dev/null || echo "Unable to check replication status"
        else
            echo "✗ Cannot connect to primary database"
            replica_db_healthy=false
        fi
        
    else
        echo "✗ Replica services are not running"
        replica_kc_healthy=false
        replica_db_healthy=false
    fi
    
    return 0
}

function check_all() {
    check_primary
    echo ""
    echo "================================"
    echo ""
    check_replica
    
    echo ""
    echo "=== Overall System Status ==="
    
    local overall_status="HEALTHY"
    local status_details=""
    
    if [ "$primary_kc_healthy" = true ] && [ "$primary_db_healthy" = true ]; then
        status_details="✓ Primary: HEALTHY"
    else
        status_details="✗ Primary: UNHEALTHY"
        overall_status="DEGRADED"
    fi
    
    if [ "$replica_kc_healthy" = true ] && [ "$replica_db_healthy" = true ]; then
        status_details="$status_details, ✓ Replica: HEALTHY"
    else
        status_details="$status_details, ✗ Replica: UNHEALTHY"
        if [ "$overall_status" = "DEGRADED" ]; then
            overall_status="CRITICAL"
        else
            overall_status="DEGRADED"
        fi
    fi
    
    echo "Status: $overall_status"
    echo "Details: $status_details"
    
    case "$overall_status" in
        "HEALTHY")
            echo "✓ Both primary and replica are functioning normally"
            return 0
            ;;
        "DEGRADED")
            echo "⚠ One instance is down but service can continue"
            return 1
            ;;
        "CRITICAL")
            echo "✗ Both instances have issues - immediate attention required"
            return 2
            ;;
    esac
}

function monitor_continuous() {
    echo "Starting continuous monitoring (Ctrl+C to stop)..."
    echo "Checking every 30 seconds..."
    echo ""
    
    while true; do
        clear
        echo "=== Continuous Monitoring ==="
        check_all
        echo ""
        echo "Next check in 30 seconds... (Ctrl+C to stop)"
        sleep 30
    done
}

# Initialize health variables
primary_kc_healthy=false
primary_db_healthy=false
replica_kc_healthy=false
replica_db_healthy=false

# Parse command line arguments
case "${1:-all}" in
    primary)
        check_primary
        ;;
    replica)
        check_replica
        ;;
    all)
        check_all
        ;;
    monitor)
        monitor_continuous
        ;;
    *)
        usage
        ;;
esac