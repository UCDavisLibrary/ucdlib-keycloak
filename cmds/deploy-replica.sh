#!/bin/bash

###
# Deploy replica Keycloak instance with PostgreSQL replica database
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

source ./config.sh

function usage() {
    echo "Usage: $0 [up|down|status|logs]"
    echo ""
    echo "Commands:"
    echo "  up      - Start replica instance"
    echo "  down    - Stop replica instance"
    echo "  status  - Show status of replica services"
    echo "  logs    - Show logs of replica services"
    echo ""
    echo "Prerequisites:"
    echo "  - PRIMARY_DB_HOST must be set in .env file"
    echo "  - Primary instance must be running and accessible"
    echo "  - Replication credentials must match primary"
    exit 1
}

function deploy_replica() {
    echo "Deploying replica Keycloak instance..."
    
    # Check required environment variables
    if [ -z "$PRIMARY_DB_HOST" ]; then
        echo "ERROR: PRIMARY_DB_HOST must be set in .env file"
        echo "Example: PRIMARY_DB_HOST=192.168.1.100"
        exit 1
    fi
    
    if [ -z "$POSTGRES_REPLICATION_USER" ] || [ -z "$POSTGRES_REPLICATION_PASSWORD" ]; then
        echo "ERROR: POSTGRES_REPLICATION_USER and POSTGRES_REPLICATION_PASSWORD must be set in .env"
        exit 1
    fi
    
    # Test connectivity to primary database
    echo "Testing connectivity to primary database at $PRIMARY_DB_HOST:5432..."
    if ! nc -z "$PRIMARY_DB_HOST" 5432; then
        echo "ERROR: Cannot connect to primary database at $PRIMARY_DB_HOST:5432"
        echo "Please ensure:"
        echo "  1. Primary instance is running"
        echo "  2. PRIMARY_DB_HOST is correct"
        echo "  3. Network connectivity exists"
        exit 1
    fi
    
    echo "Primary database is accessible."
    
    # Start replica services
    docker compose -f docker-compose.replica.yaml up -d
    
    echo ""
    echo "Replica instance deployment started!"
    echo "Keycloak Replica: http://localhost:3124 (read-only)"
    echo "Database Replica: localhost:5433"
    echo ""
    echo "Note: Initial replication setup may take a few minutes."
    echo "Use './cmds/deploy-replica.sh status' to monitor progress."
}

function stop_replica() {
    echo "Stopping replica Keycloak instance..."
    docker compose -f docker-compose.replica.yaml down
    echo "Replica instance stopped."
}

function show_status() {
    echo "=== Replica Instance Status ==="
    docker compose -f docker-compose.replica.yaml ps
    
    echo ""
    echo "=== Health Checks ==="
    
    # Check Keycloak replica health
    echo -n "Keycloak replica health: "
    if curl -sf "http://localhost:3124/health/ready" > /dev/null 2>&1; then
        echo "✓ HEALTHY (read-only)"
    else
        echo "✗ UNHEALTHY"
    fi
    
    # Check database replica health
    echo -n "Database replica health: "
    if docker compose -f docker-compose.replica.yaml exec -T db-replica pg_isready > /dev/null 2>&1; then
        echo "✓ HEALTHY"
    else
        echo "✗ UNHEALTHY"
    fi
    
    # Check replication status
    echo ""
    echo "=== Replication Status ==="
    echo -n "Primary connection: "
    if [ -n "$PRIMARY_DB_HOST" ] && nc -z "$PRIMARY_DB_HOST" 5432; then
        echo "✓ CONNECTED"
        
        # Check replication lag
        echo "Checking replication lag..."
        docker compose -f docker-compose.replica.yaml exec -T db-replica psql -U $KC_DB_USERNAME -d postgres -c "
        SELECT 
            CASE 
                WHEN pg_is_in_recovery() THEN 'Replica (standby)'
                ELSE 'Primary'
            END as server_type,
            pg_last_wal_receive_lsn() as last_received,
            pg_last_wal_replay_lsn() as last_replayed,
            EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp())) as lag_seconds;
        " 2>/dev/null || echo "Unable to check replication status"
    else
        echo "✗ DISCONNECTED"
    fi
}

function show_logs() {
    docker compose -f docker-compose.replica.yaml logs -f
}

# Parse command line arguments
case "${1:-}" in
    up)
        deploy_replica
        ;;
    down)
        stop_replica
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    *)
        usage
        ;;
esac