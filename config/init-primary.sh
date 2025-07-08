#!/bin/bash

# PostgreSQL initialization script for primary server
# Sets up replication user and permissions

set -e

echo "Setting up PostgreSQL replication..."

# Wait for PostgreSQL to be ready
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

# Create replication user if it doesn't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE USER replicator' WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replicator')\gexec
    ALTER USER replicator WITH REPLICATION ENCRYPTED PASSWORD '${POSTGRES_REPLICATION_PASSWORD}';
    GRANT CONNECT ON DATABASE postgres TO replicator;
EOSQL

echo "Replication user setup complete."

# Create WAL archive directory
mkdir -p /var/lib/postgresql/archive
chown postgres:postgres /var/lib/postgresql/archive

echo "PostgreSQL primary setup complete."