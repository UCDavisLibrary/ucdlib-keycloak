# Distributed High Availability Setup Guide

This guide provides detailed instructions for setting up Keycloak in a distributed high availability configuration across two VMs with PostgreSQL streaming replication.

## Architecture Overview

```
┌─────────────────┐         ┌─────────────────┐
│   Primary VM    │         │   Replica VM    │
│                 │         │                 │
│ ┌─────────────┐ │         │ ┌─────────────┐ │
│ │  Keycloak   │ │         │ │ Keycloak    │ │
│ │ (R/W)       │ │         │ │ (R/O)       │ │
│ │ Port: 3123  │ │         │ │ Port: 3124  │ │
│ └─────────────┘ │         │ └─────────────┘ │
│         │       │         │         │       │
│ ┌─────────────┐ │  Repl   │ ┌─────────────┐ │
│ │ PostgreSQL  │◄├─────────┤►│ PostgreSQL  │ │
│ │ (Primary)   │ │         │ │ (Replica)   │ │
│ │ Port: 5432  │ │         │ │ Port: 5433  │ │
│ └─────────────┘ │         │ └─────────────┘ │
└─────────────────┘         └─────────────────┘
```

## Prerequisites

### Infrastructure
- Two VMs with Docker and Docker Compose installed
- Network connectivity between VMs on ports 5432 and 5433
- Sufficient disk space for database storage and WAL files

### Software Requirements
- Docker 20.10+ 
- Docker Compose 2.0+
- Network tools: `nc` (netcat) for connectivity testing

## Step-by-Step Setup

### Step 1: Prepare Primary VM

1. **Clone repository and navigate to directory:**
   ```bash
   git clone <repository-url>
   cd keycloak-deployment
   ```

2. **Run primary setup:**
   ```bash
   ./cmds/setup-distributed.sh primary
   ```
   
   This will prompt for:
   - Database username (default: keycloak)
   - Database password
   - Replication user password

3. **Deploy primary instance:**
   ```bash
   ./cmds/deploy-primary.sh up
   ```

4. **Verify primary deployment:**
   ```bash
   ./cmds/deploy-primary.sh status
   ```

5. **Note the primary VM's IP address** for replica configuration:
   ```bash
   ip addr show | grep inet
   ```

### Step 2: Prepare Replica VM

1. **Clone repository and navigate to directory:**
   ```bash
   git clone <repository-url>
   cd keycloak-deployment
   ```

2. **Run replica setup:**
   ```bash
   ./cmds/setup-distributed.sh replica
   ```
   
   This will prompt for:
   - Primary VM IP address
   - Database username (must match primary)
   - Database password (must match primary)
   - Replication user password (must match primary)

3. **Deploy replica instance:**
   ```bash
   ./cmds/deploy-replica.sh up
   ```

4. **Verify replica deployment:**
   ```bash
   ./cmds/deploy-replica.sh status
   ```

### Step 3: Verify Replication

1. **On replica VM, check replication status:**
   ```bash
   ./cmds/health-check-distributed.sh replica
   ```

2. **On primary VM, check connected replicas:**
   ```bash
   ./cmds/health-check-distributed.sh primary
   ```

3. **Test data replication:**
   - Create test data in primary Keycloak
   - Verify it appears in replica Keycloak (read-only)

## Daily Operations

### Health Monitoring

```bash
# Check all instances
./cmds/health-check-distributed.sh all

# Continuous monitoring
./cmds/health-check-distributed.sh monitor
```

### Viewing Logs

```bash
# Primary VM
./cmds/deploy-primary.sh logs

# Replica VM  
./cmds/deploy-replica.sh logs
```

### Stopping Services

```bash
# Primary VM
./cmds/deploy-primary.sh down

# Replica VM
./cmds/deploy-replica.sh down
```

## Troubleshooting

### Common Issues

1. **Replica cannot connect to primary:**
   - Check network connectivity: `nc -z <primary-ip> 5432`
   - Verify firewall settings
   - Check primary VM is running

2. **Replication lag is high:**
   - Check network bandwidth between VMs
   - Monitor disk I/O on both VMs
   - Review PostgreSQL logs

3. **Keycloak replica shows as unhealthy:**
   - Check if database replica is ready
   - Verify database connectivity
   - Review Keycloak logs for specific errors

### Log Locations

- **Docker Compose logs:** `docker compose logs <service>`
- **PostgreSQL logs:** Inside container at `/var/log/postgresql/`
- **Keycloak logs:** Shown in Docker Compose logs

## Disaster Recovery

### Primary VM Failure

1. **Immediate response:**
   - Update DNS/load balancer to point to replica VM
   - Monitor replica for increased load

2. **Promote replica to primary (manual process):**
   ```bash
   # On replica VM
   docker compose -f docker-compose.replica.yaml exec db-replica \
     psql -U keycloak -d postgres -c "SELECT pg_promote();"
   ```

3. **Restart Keycloak without read-only restrictions:**
   - Stop replica Keycloak
   - Update configuration to remove read-only settings
   - Restart Keycloak

### Replica VM Failure

1. **Primary continues serving traffic**
2. **Fix replica VM issues**
3. **Rebuild replica from primary:**
   ```bash
   ./cmds/deploy-replica.sh down
   # Remove old data
   docker volume rm keycloak-deployment_db-replica-data
   ./cmds/deploy-replica.sh up
   ```

## Maintenance

### Updating Keycloak Version

1. **Update config.sh with new version**
2. **Update primary first:**
   ```bash
   ./cmds/deploy-primary.sh down
   docker compose -f docker-compose.primary.yaml pull
   ./cmds/deploy-primary.sh up
   ```
3. **Update replica after primary is verified:**
   ```bash
   ./cmds/deploy-replica.sh down
   docker compose -f docker-compose.replica.yaml pull
   ./cmds/deploy-replica.sh up
   ```

### Database Maintenance

- **Backups:** Run on primary VM only
- **Vacuum/Analyze:** Performed automatically
- **Monitoring:** Use provided health check scripts

## Security Considerations

1. **Network Security:**
   - Use VPN or private networks between VMs
   - Configure firewalls to allow only necessary ports
   - Use strong passwords for replication user

2. **Database Security:**
   - Encrypt replication traffic (configure SSL)
   - Regularly rotate passwords
   - Monitor access logs

3. **Application Security:**
   - Keep Keycloak updated
   - Monitor for security advisories
   - Use HTTPS for all Keycloak traffic

## Performance Tuning

### PostgreSQL Settings

Edit `config/postgresql.conf` for your environment:
- `shared_buffers`: 25% of RAM
- `wal_keep_size`: Based on network reliability
- `max_connections`: Based on expected load

### Keycloak Settings

- Monitor JVM heap usage
- Adjust database connection pool sizes
- Configure session storage appropriately

## Support

For issues with this deployment:
1. Check this documentation
2. Review logs using provided scripts
3. Test connectivity between VMs
4. Verify configuration files match between VMs