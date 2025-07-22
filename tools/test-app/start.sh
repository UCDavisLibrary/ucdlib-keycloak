#!/bin/bash

# Convenience script to start the Keycloak auth tester app
# Usage: ./start.sh <KC_REALM> <KC_CLIENT_ID> [PORT]

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <KC_REALM> <KC_CLIENT_ID> [PORT]"
    echo ""
    echo "Required arguments:"
    echo "  KC_REALM      - Keycloak realm name"
    echo "  KC_CLIENT_ID  - Keycloak client ID"
    echo ""
    echo "Optional arguments:"
    echo "  PORT          - Server port (default: 3000)"
    echo ""
    echo "Example:"
    echo "  $0 master auth-tester 3000"
    exit 1
fi

# Set required environment variables
export KC_REALM="$1"
export KC_CLIENT_ID="$2"

# Set optional PORT if provided
if [ $# -ge 3 ]; then
    export PORT="$3"
fi

# Display configuration
echo "Starting Keycloak Auth Tester with:"
echo "  KC_REALM: $KC_REALM"
echo "  KC_CLIENT_ID: $KC_CLIENT_ID"
echo "  PORT: ${PORT:-3000}"
echo ""

# Start the application
npm start
