#!/bin/bash
set -e

# Only run setup if the data directory is empty
if [ -z "$(ls -A "/var/lib/postgresql/data")" ]; then
  echo "Initializing standby server..."

  # Set permissions for /var/lib/postgresql/data directory
  chmod 0700 /var/lib/postgresql/data
  chown -R postgres:postgres /var/lib/postgresql/data

  # Switch to postgres user for pg_basebackup
  su - postgres -c "PGPASSWORD=replica_pass pg_basebackup -h postgres-primary -p 5432 -U replica_user -D /var/lib/postgresql/data -P -v -R"

  # Create and configure standby.signal file
  touch /var/lib/postgresql/data/standby.signal
  chown postgres:postgres /var/lib/postgresql/data/standby.signal

  # Append important settings to postgresql.auto.conf
  echo "hot_standby = on" >> /var/lib/postgresql/data/postgresql.auto.conf
  echo "primary_conninfo = 'host=postgres-primary port=5432 user=replica_user password=replica_pass application_name=standby'" >> /var/lib/postgresql/data/postgresql.auto.conf

  # Ensure proper permissions on postgresql.auto.conf
  chown postgres:postgres /var/lib/postgresql/data/postgresql.auto.conf

  echo "Standby server initialization completed"
fi

# Start PostgreSQL using the default Docker entrypoint
exec docker-entrypoint.sh postgres
