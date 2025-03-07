#!/bin/bash
echo "------------------------------"
echo "Fetching logs from primary..."
echo "------------------------------"

docker logs postgres-primary --tail 10
echo ""
echo "------------------------------"
echo "Fetching logs from standby..."
echo "------------------------------"
docker logs postgres-standby --tail 10
