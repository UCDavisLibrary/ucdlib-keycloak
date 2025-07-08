#!/bin/bash

###
# Setup script for distributed Keycloak deployment
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

function usage() {
    echo "Usage: $0 [primary|replica]"
    echo ""
    echo "Commands:"
    echo "  primary  - Setup primary VM configuration"
    echo "  replica  - Setup replica VM configuration"
    echo ""
    echo "This script helps configure the .env file for distributed deployment."
    exit 1
}

function setup_primary() {
    echo "=== Setting up Primary VM Configuration ==="
    echo ""
    
    # Check if .env exists
    if [ ! -f .env ]; then
        echo "Creating .env file from .env.example..."
        cp .env.example .env
    fi
    
    echo "Configuring .env for primary VM..."
    
    # Prompt for basic database credentials
    read -p "Enter database username (default: keycloak): " db_user
    db_user=${db_user:-keycloak}
    
    read -s -p "Enter database password: " db_pass
    echo ""
    
    read -s -p "Enter replication user password: " repl_pass
    echo ""
    
    # Update .env file
    sed -i "s/KC_DB_USERNAME=.*/KC_DB_USERNAME=$db_user/" .env
    sed -i "s/KC_DB_PASSWORD=.*/KC_DB_PASSWORD=$db_pass/" .env
    sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$db_pass/" .env
    
    # Add replication settings
    if ! grep -q "POSTGRES_REPLICATION_USER" .env; then
        echo "" >> .env
        echo "# Replication Configuration" >> .env
        echo "POSTGRES_REPLICATION_USER=replicator" >> .env
        echo "POSTGRES_REPLICATION_PASSWORD=$repl_pass" >> .env
    else
        sed -i "s/POSTGRES_REPLICATION_PASSWORD=.*/POSTGRES_REPLICATION_PASSWORD=$repl_pass/" .env
    fi
    
    echo ""
    echo "✓ Primary VM configuration complete!"
    echo ""
    echo "Next steps:"
    echo "1. Deploy primary instance: ./cmds/deploy-primary.sh up"
    echo "2. Get the IP address of this VM for replica configuration"
    echo "3. Configure replica VM using this IP address"
}

function setup_replica() {
    echo "=== Setting up Replica VM Configuration ==="
    echo ""
    
    # Check if .env exists
    if [ ! -f .env ]; then
        echo "Creating .env file from .env.example..."
        cp .env.example .env
    fi
    
    echo "Configuring .env for replica VM..."
    
    # Prompt for primary database details
    read -p "Enter primary VM IP address: " primary_ip
    if [ -z "$primary_ip" ]; then
        echo "ERROR: Primary IP address is required"
        exit 1
    fi
    
    read -p "Enter database username (default: keycloak): " db_user
    db_user=${db_user:-keycloak}
    
    read -s -p "Enter database password: " db_pass
    echo ""
    
    read -s -p "Enter replication user password: " repl_pass
    echo ""
    
    # Update .env file
    sed -i "s/KC_DB_USERNAME=.*/KC_DB_USERNAME=$db_user/" .env
    sed -i "s/KC_DB_PASSWORD=.*/KC_DB_PASSWORD=$db_pass/" .env
    sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$db_pass/" .env
    
    # Add primary and replication settings
    if ! grep -q "PRIMARY_DB_HOST" .env; then
        echo "" >> .env
        echo "# Primary Database Connection" >> .env
        echo "PRIMARY_DB_HOST=$primary_ip" >> .env
    else
        sed -i "s/PRIMARY_DB_HOST=.*/PRIMARY_DB_HOST=$primary_ip/" .env
    fi
    
    if ! grep -q "POSTGRES_REPLICATION_USER" .env; then
        echo "" >> .env
        echo "# Replication Configuration" >> .env
        echo "POSTGRES_REPLICATION_USER=replicator" >> .env
        echo "POSTGRES_REPLICATION_PASSWORD=$repl_pass" >> .env
    else
        sed -i "s/POSTGRES_REPLICATION_PASSWORD=.*/POSTGRES_REPLICATION_PASSWORD=$repl_pass/" .env
    fi
    
    # Test connectivity to primary
    echo ""
    echo "Testing connectivity to primary database at $primary_ip:5432..."
    if nc -z "$primary_ip" 5432; then
        echo "✓ Primary database is accessible"
    else
        echo "⚠ Warning: Cannot connect to primary database"
        echo "  Make sure the primary instance is running and accessible"
    fi
    
    echo ""
    echo "✓ Replica VM configuration complete!"
    echo ""
    echo "Next steps:"
    echo "1. Ensure primary instance is running"
    echo "2. Deploy replica instance: ./cmds/deploy-replica.sh up"
    echo "3. Monitor health: ./cmds/health-check-distributed.sh all"
}

function show_status() {
    echo "=== Current Configuration Status ==="
    echo ""
    
    if [ -f .env ]; then
        echo "Configuration file (.env) exists"
        
        if grep -q "PRIMARY_DB_HOST=" .env && [ -n "$(grep "PRIMARY_DB_HOST=" .env | cut -d'=' -f2)" ]; then
            echo "✓ Configured as: REPLICA VM"
            echo "  Primary DB Host: $(grep "PRIMARY_DB_HOST=" .env | cut -d'=' -f2)"
        else
            echo "✓ Configured as: PRIMARY VM"
        fi
        
        echo ""
        echo "Database user: $(grep "KC_DB_USERNAME=" .env | cut -d'=' -f2)"
        echo "Replication user: $(grep "POSTGRES_REPLICATION_USER=" .env 2>/dev/null | cut -d'=' -f2 || echo 'Not configured')"
    else
        echo "✗ Configuration file (.env) not found"
        echo "  Run setup to create configuration"
    fi
    
    echo ""
    echo "Available deployment files:"
    [ -f docker-compose.primary.yaml ] && echo "  ✓ docker-compose.primary.yaml"
    [ -f docker-compose.replica.yaml ] && echo "  ✓ docker-compose.replica.yaml"
    [ -f docker-compose.yaml ] && echo "  ✓ docker-compose.yaml (original single-node)"
}

# Parse command line arguments
case "${1:-}" in
    primary)
        setup_primary
        ;;
    replica)
        setup_replica
        ;;
    status)
        show_status
        ;;
    *)
        show_status
        echo ""
        usage
        ;;
esac