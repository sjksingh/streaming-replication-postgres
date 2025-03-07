#!/bin/bash

echo ""
echo "Step 1: Creating table on primary..."
echo "Command: docker exec -it postgres-primary psql -U postgres -d mydb -c \"CREATE TABLE IF NOT EXISTS test_replication (id SERIAL PRIMARY KEY, name TEXT, created_at TIMESTAMP DEFAULT NOW());\""
docker exec -it postgres-primary psql -U postgres -d mydb -c "CREATE TABLE IF NOT EXISTS test_replication (id SERIAL PRIMARY KEY, name TEXT, created_at TIMESTAMP DEFAULT NOW());"

echo ""
echo "Step 2: Inserting test data into primary..."
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "Command: docker exec -it postgres-primary psql -U postgres -d mydb -c \"INSERT INTO test_replication (name, created_at) VALUES ('Replication Test', '$TIMESTAMP');\""
docker exec -it postgres-primary psql -U postgres -d mydb -c "INSERT INTO test_replication (name, created_at) VALUES ('Replication Test', '$TIMESTAMP');"

echo ""
echo "Step 3: Checking if data is replicated to standby..."
echo "Command: docker exec -it postgres-standby psql -U postgres -d mydb -c \"SELECT * FROM test_replication ORDER BY created_at DESC LIMIT 1;\""
docker exec -it postgres-standby psql -U postgres -d mydb -c "SELECT * FROM test_replication ORDER BY created_at DESC LIMIT 1;"
[sanjeev@ssdnodes-5fe8e273597c4 scripts]$
