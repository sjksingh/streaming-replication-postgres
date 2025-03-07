#!/bin/bash

# Function to check which node is primary
get_primary() {
    if docker exec -it postgres-primary psql -U postgres -c "SELECT pg_is_in_recovery();" | grep -q "f"; then
        echo "postgres-primary"
    elif docker exec -it postgres-standby psql -U postgres -c "SELECT pg_is_in_recovery();" | grep -q "f"; then
        echo "postgres-standby"
    else
        echo "ERROR: No primary found!"
        exit 1
    fi
}

# Get current primary
PRIMARY_NODE=$(get_primary)
echo "Connecting to Primary: $PRIMARY_NODE"

# Connect to the primary node
docker exec -it $PRIMARY_NODE psql -U postgres -d mydb
