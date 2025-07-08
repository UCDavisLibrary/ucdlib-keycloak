#!/bin/bash

###
# Manage hot spare configuration for Keycloak deployment
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

source ./config.sh

function usage() {
    echo "Usage: $0 [enable|disable|status]"
    echo ""
    echo "Commands:"
    echo "  enable   - Enable hot spare instance"
    echo "  disable  - Disable hot spare instance"
    echo "  status   - Show current hot spare status"
    exit 1
}

function enable_hot_spare() {
    echo "Enabling hot spare configuration..."
    
    # Update config.sh to enable hot spare
    sed -i 's/ENABLE_HOT_SPARE=false/ENABLE_HOT_SPARE=true/' config.sh
    
    # Regenerate deployment files
    ./cmds/generate-deployment-files.sh
    
    echo "Hot spare enabled. To start with hot spare, run:"
    echo "docker compose --profile hot-spare up -d"
}

function disable_hot_spare() {
    echo "Disabling hot spare configuration..."
    
    # Update config.sh to disable hot spare
    sed -i 's/ENABLE_HOT_SPARE=true/ENABLE_HOT_SPARE=false/' config.sh
    
    # Regenerate deployment files
    ./cmds/generate-deployment-files.sh
    
    echo "Hot spare disabled. Normal single-instance deployment will be used."
}

function show_status() {
    echo "Hot spare status:"
    if grep -q "ENABLE_HOT_SPARE=true" config.sh; then
        echo "  Status: ENABLED"
        echo "  Primary port: $KC_HOST_PORT"
        echo "  Spare port: $KC_SPARE_HOST_PORT"
        echo ""
        echo "To start with hot spare: docker compose --profile hot-spare up -d"
        echo "To start without hot spare: docker compose up -d"
    else
        echo "  Status: DISABLED"
        echo "  Only primary instance will run on port: $KC_HOST_PORT"
    fi
    
    echo ""
    echo "Running containers:"
    docker compose ps 2>/dev/null || echo "  No containers running"
}

# Parse command line arguments
case "${1:-}" in
    enable)
        enable_hot_spare
        ;;
    disable)
        disable_hot_spare
        ;;
    status)
        show_status
        ;;
    *)
        usage
        ;;
esac