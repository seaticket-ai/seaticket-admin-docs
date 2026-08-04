#!/bin/bash
set -e

echo "Waiting for FDB to be ready..."
until docker exec fdb fdbcli --exec "status" --timeout 5 2>/dev/null | grep -q "is healthy"; do
    echo "  still waiting..."
    sleep 3
done
echo "FDB is ready."

# init
echo "Configuring: configure new single ssd..."
docker exec fdb fdbcli --exec "configure new single ssd"

echo "Configuring: storage_migration_type=aggressive..."
docker exec fdb fdbcli --exec "configure storage_migration_type=aggressive"

echo "Configuring: configure ssd..."
docker exec fdb fdbcli --exec "configure ssd"
echo "FDB initialization completed."

echo "Final status:"
docker exec fdb fdbcli --exec "status"
