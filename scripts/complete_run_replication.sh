#!/bin/bash

echo ""
echo "🔍 Checking Primary and Standby Health..."
echo "Command: docker exec -it postgres-primary pg_isready -U postgres"
docker exec -it postgres-primary pg_isready -U postgres

echo "Command: docker exec -it postgres-standby pg_isready -U postgres"
docker exec -it postgres-standby pg_isready -U postgres

echo ""
echo "🔍 Validating Replication User..."
echo "Command: docker exec -it postgres-primary psql -U postgres -c \"SELECT * FROM pg_roles WHERE rolname='replica_user';\""
docker exec -it postgres-primary psql -U postgres -c "SELECT * FROM pg_roles WHERE rolname='replica_user';"

echo ""
echo "🔍 Checking Replication Status..."
echo "Command: docker exec -it postgres-primary psql -U postgres -c \"SELECT client_addr, state, sync_state FROM pg_stat_replication;\""
docker exec -it postgres-primary psql -U postgres -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;"

echo ""
echo "🔍 Checking if Standby is in Recovery Mode..."
echo "Command: docker exec -it postgres-standby psql -U postgres -c \"SELECT pg_is_in_recovery();\""
docker exec -it postgres-standby psql -U postgres -c "SELECT pg_is_in_recovery();"

echo ""
echo "🔍 Checking if Standby Configuration Matches Primary..."
echo "Command: docker exec -it postgres-standby cat /var/lib/postgresql/data/postgresql.auto.conf"
docker exec -it postgres-standby cat /var/lib/postgresql/data/postgresql.auto.conf

echo ""
echo "🔍 Checking Replication Lag..."
echo "Command: docker exec -it postgres-primary psql -U postgres -c \"SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag;\""
docker exec -it postgres-primary psql -U postgres -c "SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag;"


echo ""
echo "🚀 Running Replication Test: Creating Table & Inserting Data..."
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "Command: docker exec -it postgres-primary psql -U postgres -d mydb -c \"CREATE TABLE IF NOT EXISTS test_replication (id SERIAL PRIMARY KEY, name TEXT, created_at TIMESTAMP DEFAULT NOW());\""
docker exec -it postgres-primary psql -U postgres -d mydb -c "CREATE TABLE IF NOT EXISTS test_replication (id SERIAL PRIMARY KEY, name TEXT, created_at TIMESTAMP DEFAULT NOW());"

echo "Command: docker exec -it postgres-primary psql -U postgres -d mydb -c \"INSERT INTO test_replication (name, created_at) VALUES ('Replication Test - $TIMESTAMP', '$TIMESTAMP');\""
docker exec -it postgres-primary psql -U postgres -d mydb -c "INSERT INTO test_replication (name, created_at) VALUES ('Replication Test - $TIMESTAMP', '$TIMESTAMP');"

echo ""
echo "🔍 Checking if Data Replicated to Standby..."
echo "Command: docker exec -it postgres-standby psql -U postgres -d mydb -c \"SELECT * FROM test_replication ORDER BY created_at DESC LIMIT 1;\""
docker exec -it postgres-standby psql -U postgres -d mydb -c "SELECT * FROM test_replication ORDER BY created_at DESC LIMIT 1;"
