#!/bin/bash

echo ""
echo "Replication user...."
echo "Command: docker exec -it postgres-primary psql -U postgres -c \"SELECT * FROM pg_roles WHERE rolname='replica_user';\""
docker exec -it postgres-primary psql -U postgres -c "SELECT * FROM pg_roles WHERE rolname='replica_user';"

echo ""
echo "Is Replication Active....."
echo "Command: docker exec -it postgres-primary psql -U postgres -c \"SELECT client_addr, state, sync_state FROM pg_stat_replication;\""
docker exec -it postgres-primary psql -U postgres -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;"

echo ""
echo "Is standby properly configured for replication..."
echo "Command: docker exec -it postgres-standby psql -U postgres -c \"SELECT pg_is_in_recovery();\""
docker exec -it postgres-standby psql -U postgres -c "SELECT pg_is_in_recovery();"

echo ""
echo "Is standby server properly connecting..."
echo "Command: docker exec -it postgres-standby cat /var/lib/postgresql/data/postgresql.auto.conf"
docker exec -it postgres-standby cat /var/lib/postgresql/data/postgresql.auto.conf
