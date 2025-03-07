# PostgreSQL Streaming Replication Setup

A containerized setup for PostgreSQL streaming replication with primary and standby nodes.

```
                  ┌─────────────────┐                  ┌─────────────────┐
                  │                 │                  │                 │
                  │  postgres-      │                  │  postgres-      │
                  │  primary        │                  │  standby        │
                  │  :5432          │                  │  :5433          │
                  │                 │  WAL Streaming   │                 │
                  │  Read/Write     ├─────────────────►│  Read-Only      │
                  │                 │                  │                 │
                  │  WAL_LEVEL=     │                  │  HOT_STANDBY=   │
                  │  replica        │                  │  on             │
                  │                 │  pg_basebackup   │                 │
                  └─────────────────┘                  └─────────────────┘
                      ▲                                    ▲
                      │                                    │
                      │                                    │
                      │                                    │
                      │                                    │
                  ┌───┴────────────────────────────────────┴───┐
                  │                                            │
                  │           postgres_net network             │
                  │                                            │
                  └────────────────────────────────────────────┘
```

## Overview

This project sets up a PostgreSQL streaming replication environment using Docker Compose. It consists of:

- A primary PostgreSQL server that accepts read/write operations
- A standby PostgreSQL server that maintains a read-only copy of the primary
- Automatic initialization and configuration scripts
- Helper scripts for monitoring and managing the replication setup

## Features

- Streaming replication (physical) for high availability and disaster recovery
- Automatic standby initialization using `pg_basebackup`
- WAL archiving enabled on primary
- Docker-based setup for easy deployment and testing
- Helper scripts for monitoring replication status and connecting to servers

## Prerequisites

- Docker and Docker Compose
- Basic understanding of PostgreSQL replication concepts

## Quick Start

1. Clone this repository:
   ```
   git clone https://github.com/sjksingh/streaming-replication-postgres.git
   cd streaming-replication-postgres
   ```

2. Start the containers:
   ```
   docker-compose up -d
   ```

3. Verify replication is working:
   ```
   ./scripts/check_replication_status.sh
   ```

## Configuration Details

### Primary Server (postgres-primary)

- Port: 5432
- Username: postgres
- Password: primary
- Database: mydb
- Replication User: replica_user
- Replication Password: replica_pass

Key configuration settings:
- `wal_level = replica`
- `max_wal_senders = 10`
- `max_replication_slots = 10`
- `hot_standby = on`
- `archive_mode = on`

### Standby Server (postgres-standby)

- Port: 5433
- Username: postgres
- Password: standby
- Configured as a hot standby server that accepts read-only queries

## Understanding Replication

This setup uses streaming replication (physical replication), which:
- Replicates the entire database instance at the block level
- Maintains a hot standby server for read-only operations and high availability
- Streams Write-Ahead Log (WAL) records from primary to standby
- Can be used for failover in high-availability scenarios

## Helper Scripts

The project includes several helper scripts in the `/scripts` directory:

### `check_replication_status.sh`
Checks if replication is working properly by querying both servers.

### `connect_primary.sh`
Automatically connects to whichever node is currently acting as primary.

### `logs.sh`
Shows the most recent logs from both primary and standby servers.

## Testing Replication

1. Connect to the primary server:
   ```
   docker exec -it postgres-primary psql -U postgres -d mydb
   ```

2. Create a test table and insert data:
   ```sql
   CREATE TABLE test (id SERIAL PRIMARY KEY, data TEXT);
   INSERT INTO test (data) VALUES ('test data');
   ```

3. Connect to the standby server to verify the data is replicated:
   ```
   docker exec -it postgres-standby psql -U postgres -d mydb
   ```

4. Query the test table:
   ```sql
   SELECT * FROM test;
   ```

## Failover (Manual)

To perform a manual failover:

1. Stop the primary server:
   ```
   docker stop postgres-primary
   ```

2. Promote the standby to primary:
   ```
   docker exec -it postgres-standby pg_ctl promote -D /var/lib/postgresql/data
   ```

3. Verify the standby is now a primary:
   ```
   docker exec -it postgres-standby psql -U postgres -c "SELECT pg_is_in_recovery();"
   ```
   This should return `f` indicating the server is no longer in recovery mode.

## Limitations and Considerations

- This setup does not include automated failover
- No replication slots are configured, which might lead to WAL retention issues if the standby server disconnects for an extended period
- For production use, consider adding monitoring and automated failover solutions

## Troubleshooting

If replication is not working:

1. Check the logs for both servers:
   ```
   ./scripts/logs.sh
   ```

2. Verify network connectivity between containers:
   ```
   docker exec -it postgres-primary ping postgres-standby
   ```

3. Verify replication user exists and has proper permissions:
   ```
   docker exec -it postgres-primary psql -U postgres -c "SELECT * FROM pg_roles WHERE rolname='replica_user';"
   ```

4. Check standby's connection string:
   ```
   docker exec -it postgres-standby cat /var/lib/postgresql/data/postgresql.auto.conf
   ```
