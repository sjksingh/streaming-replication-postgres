#!/bin/bash
set -e

# Create replica_user for replication
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER replica_user WITH REPLICATION PASSWORD 'replica_pass';
EOSQL

# Ensure archive directory exists
mkdir -p /var/lib/postgresql/data/archive

# Add replication configuration to postgresql.conf
cat >> /var/lib/postgresql/data/postgresql.conf <<CONF
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
hot_standby = on
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/data/archive/%f'
CONF

# Update pg_hba.conf to allow replication connections from any host in the network
cat >> /var/lib/postgresql/data/pg_hba.conf <<CONF
# Allow replication connections from all hosts in the docker network
host    replication     replica_user     all     md5
CONF

echo "Primary server configured for replication"
