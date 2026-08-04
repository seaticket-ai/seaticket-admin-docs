#!/bin/bash
set -e

echo "Waiting for FDB to be ready..."
sleep 5

# init
echo "Configuring: configure new single ssd..."
docker exec fdb fdbcli --exec "configure new single ssd"

echo "Configuring: storage_migration_type=aggressive..."
docker exec fdb fdbcli --exec "configure storage_migration_type=aggressive"

echo "Configuring: configure ssd..."
docker exec fdb fdbcli --exec "configure ssd"

echo "Fdb status:"
docker exec fdb fdbcli --exec "status"

echo ""
echo "FDB initialization completed."
echo ""
