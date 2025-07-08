#!/bin/bash

###
# Deploy primary Keycloak instance with PostgreSQL primary database
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

source ./config.sh

function usage() {
    echo "Usage: $0 [up|down|status|logs]"
    echo ""
    echo "Commands:"
    echo "  up      - Start primary instance"
    echo "  down    - Stop primary instance"
    echo "  status  - Show status of primary services"
    echo "  logs    - Show logs of primary services"
    exit 1
}

function deploy_primary() {
    echo "Deploying primary Keycloak instance..."
    
    # Check if replication user environment variables are set
    if [ -z "$POSTGRES_REPLICATION_USER" ] || [ -z "$POSTGRES_REPLICATION_PASSWORD" ]; then
        echo "Warning: POSTGRES_REPLICATION_USER and POSTGRES_REPLICATION_PASSWORD should be set in .env for replication"
    fi
    
    # Create archive directory for WAL files
    mkdir -p ./archive
    
    # Start primary services
    docker compose -f docker-compose.primary.yaml up -d
    
    echo ""
    echo "Primary instance deployed successfully!"
    echo "Keycloak: http://localhost:$KC_HOST_PORT"
    echo "Database: localhost:5432"
    echo ""
    echo "To deploy replica on another VM, use:"
    echo "  ./cmds/deploy-replica.sh up"
}

function stop_primary() {
    echo "Stopping primary Keycloak instance..."
    docker compose -f docker-compose.primary.yaml down
    echo "Primary instance stopped."
}

function show_status() {
    echo "=== Primary Instance Status ==="
    docker compose -f docker-compose.primary.yaml ps
    
    echo ""
    echo "=== Health Checks ==="
    
    # Check Keycloak health
    echo -n "Keycloak health: "
    if curl -sf "http://localhost:$KC_HOST_PORT/health/ready" > /dev/null 2>&1; then
        echo "✓ HEALTHY"
    else
        echo "✗ UNHEALTHY"
    fi
    
    # Check database health
    echo -n "Database health: "
    if docker compose -f docker-compose.primary.yaml exec -T db pg_isready > /dev/null 2>&1; then
        echo "✓ HEALTHY"
    else
        echo "✗ UNHEALTHY"
    fi
    
    # Check replication status
    echo ""
    echo "=== Replication Status ==="
    docker compose -f docker-compose.primary.yaml exec -T db psql -U $KC_DB_USERNAME -d postgres -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;" 2>/dev/null || echo "No replicas connected"
}

function show_logs() {
    docker compose -f docker-compose.primary.yaml logs -f
}

# Parse command line arguments
case "${1:-}" in
    up)
        deploy_primary
        ;;
    down)
        stop_primary
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