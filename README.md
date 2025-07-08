# Keycloak Deployment

[Keycloak](https://www.keycloak.org/) is the Identity and Access Management system used by the UC Davis Library. It primarily acts as an identity broker for the UC Davis Central Authentication System (CAS).

## High Availability Deployment Options

This deployment supports two high availability configurations:

### 1. Single-VM Hot Spare (Legacy)
A simpler setup where both Keycloak instances run on the same VM sharing one database.

### 2. Distributed High Availability (Recommended)
A robust multi-VM setup with PostgreSQL streaming replication and read-only replica Keycloak instances.

## Distributed High Availability Setup

The distributed setup provides true high availability across separate VMs with PostgreSQL streaming replication.

### Architecture
- **Primary VM**: Keycloak + PostgreSQL primary database
- **Replica VM**: Keycloak (read-only) + PostgreSQL replica database
- **Automatic Replication**: Real-time data synchronization between databases
- **Failover**: Manual or automated failover to replica VM

### Initial Setup

#### On Primary VM:
```bash
# Setup primary configuration
./cmds/setup-distributed.sh primary

# Deploy primary instance
./cmds/deploy-primary.sh up
```

#### On Replica VM:
```bash
# Setup replica configuration (requires primary VM IP)
./cmds/setup-distributed.sh replica

# Deploy replica instance
./cmds/deploy-replica.sh up
```

### Management Commands

#### Primary VM Operations:
```bash
# Deploy/start primary
./cmds/deploy-primary.sh up

# Stop primary
./cmds/deploy-primary.sh down

# Check primary status
./cmds/deploy-primary.sh status

# View primary logs
./cmds/deploy-primary.sh logs
```

#### Replica VM Operations:
```bash
# Deploy/start replica
./cmds/deploy-replica.sh up

# Stop replica
./cmds/deploy-replica.sh down

# Check replica status
./cmds/deploy-replica.sh status

# View replica logs
./cmds/deploy-replica.sh logs
```

### Health Monitoring

```bash
# Check all instances
./cmds/health-check-distributed.sh all

# Check only primary
./cmds/health-check-distributed.sh primary

# Check only replica
./cmds/health-check-distributed.sh replica

# Continuous monitoring
./cmds/health-check-distributed.sh monitor
```

### Single-VM Hot Spare (Legacy)

For backward compatibility, the original single-VM hot spare is still available:

```bash
# Enable hot spare
./cmds/manage-hot-spare.sh enable

# Deploy with hot spare
docker compose --profile hot-spare up -d

# Check status
./cmds/health-check.sh
```

## Environment Variables

### Basic Configuration
| Variable | Description | Required? |
| -------- | ----------- | --------- |
| KC_DB_USERNAME | PostgreSQL username | Y |
| KC_DB_PASSWORD | PostgreSQL password | Y |
| POSTGRES_PASSWORD | Same as KC_DB_PASSWORD | Y |
| KEYCLOAK_ADMIN | Creates KC admin user on start | Only for initial setup |
| KEYCLOAK_ADMIN_PASSWORD | KC admin user password | Only for initial setup |

### Distributed HA Configuration
| Variable | Description | Required? |
| -------- | ----------- | --------- |
| PRIMARY_DB_HOST | IP address of primary VM | Y (replica only) |
| POSTGRES_REPLICATION_USER | Replication username | Y (both VMs) |
| POSTGRES_REPLICATION_PASSWORD | Replication password | Y (both VMs) |

### Network Requirements

For distributed deployment:
- **Port 5432**: PostgreSQL primary (primary VM)
- **Port 5433**: PostgreSQL replica (replica VM)  
- **Port 3123**: Keycloak primary (primary VM)
- **Port 3124**: Keycloak replica (replica VM)
- **Network connectivity** between VMs for database replication

## Deployment Process

### Distributed Deployment (Recommended)

1. **Setup Primary VM:**
   ```bash
   ./cmds/setup-distributed.sh primary
   ./cmds/deploy-primary.sh up
   ```

2. **Setup Replica VM:**
   ```bash
   ./cmds/setup-distributed.sh replica
   ./cmds/deploy-replica.sh up
   ```

3. **Verify deployment:**
   ```bash
   ./cmds/health-check-distributed.sh all
   ```

### Legacy Single-VM Deployment

1. Check `config.sh` configuration
2. Run `./cmds/generate-deployment-files.sh`
3. Deploy: `docker compose up -d` or `docker compose --profile hot-spare up -d`

## Failover Procedures

### Manual Failover to Replica
1. Stop primary services: `./cmds/deploy-primary.sh down`
2. Promote replica to primary (requires manual PostgreSQL promotion)
3. Update DNS/load balancer to point to replica VM
4. Restart replica Keycloak without read-only restrictions

### Recovery Procedures
1. Fix primary VM issues
2. Restore primary from replica backup
3. Re-establish replication
4. Failback to primary when ready

