# Setup SeaDB cluster

SeaDB depends on [FoundationDB](https://apple.github.io/foundationdb/). 

FoundationDB is a distributed database designed to handle large volumes of structured data across clusters of commodity servers.

## Deploy FoundationDB Cluster

This guide uses a three-node FoundationDB`(v7.3.63)` setup as an example `cluster-fdb1(192.168.0.10), cluster-fdb2(192.168.0.11), cluster-fdb3(192.168.0.12)`. Each node runs two fdbserver processes, and each fdbserver process uses its own dedicated SSD data disk (`/fdb1` and `/fdb2`). Unless otherwise specified, the following steps should be performed on all three nodes. For more information, please refer to the [official documentation](https://apple.github.io/foundationdb/building-cluster.html?wework_cfm_code=N62oKwB0BwL1eIEfRQ9gi2JYDKFJ2GVPsa4FeatkT5iEMS5q30ZBfJXubqhrhrPzBj07eBXsZFkcrCwzIDbgR4x13xzFY7o2zieAtTi5VZHWQn8SBMg2YjrV2X1If2DQiA%3D%3D).

### FoundationDB Installation

Install FoundationDB on each node according to the [official documentation](https://apple.github.io/foundationdb/getting-started-linux.html).

Then, you need to stop the service and migrate existing data to the new directory.

```shell
# Stop the service
systemctl stop foundationdb || service foundationdb stop

# Create data directories
mkdir -p /fdb1/foundationdb/data/4500 /fdb1/foundationdb/log/4500
mkdir -p /fdb2/foundationdb/data/4501 /fdb2/foundationdb/log/4501

# Migrate existing data
rsync -aHAX --numeric-ids /var/lib/foundationdb/data/4500/ /fdb1/foundationdb/data/4500/
# If the second fdbserver process has not been started, you don’t need to run this step.
rsync -aHAX --numeric-ids /var/lib/foundationdb/data/4501/ /fdb2/foundationdb/data/4501/

# Update permissions
chown -R foundationdb:foundationdb /fdb1/foundationdb /fdb2/foundationdb
chmod 700 /fdb1/foundationdb/data/4500 /fdb2/foundationdb/data/4501
chmod 755 /fdb1/foundationdb/log/4500 /fdb2/foundationdb/log/4501
```

### Modify `foundationdb.conf`

Specify `datadir` and `logdir` separately for each fdbserver process. Assign a `class` role to each fdbserver process.

In the existing configuration, keep the default [fdbserver] section unchanged, and add the two fdbserver process configurations as follows:

```shell
[fdbserver.4500]
class  = transaction
datadir = /fdb1/foundationdb/data/4500
logdir  = /fdb1/foundationdb/log/4500

[fdbserver.4501]
class  = storage
datadir = /fdb2/foundationdb/data/4501
logdir  = /fdb2/foundationdb/log/4501
```

### Start the FoundationDB service

Check whether the foundationdb processes have started, and verify that the cluster status and the role/class identity of each process are correct.

```shell
systemctl start foundationdb || service foundationdb start

ss -lntp | egrep ':4500|:4501' || true

fdbcli --exec "status json" \
| jq -r '.cluster.processes
         | to_entries[]
         | "\(.value.address)\tclass=\(.value.class_type // "unset")\troles=\((.value.roles // [])|map(.role)|unique|join(","))"'
         
192.168.0.12:4501   class=storage  roles=ratekeeper,storage
192.168.0.11:4500   class=transaction  roles=cluster_controller,coordinator,log,resolver
192.168.0.12:4500   class=transaction  roles=commit_proxy,coordinator,grv_proxy,log
192.168.0.10:4500   class=transaction  roles=commit_proxy,coordinator,log,master
192.168.0.10:4501   class=storage  roles=data_distributor,storage
192.168.0.11:4501   class=storage  roles=consistency_scan,storage

fdbcli
> status details
```

### Configure FoundationDB for external access

Run the following on `cluster-fdb1`.

```shell
python3 /usr/lib/foundationdb/make_public.py # Generate the externally accessible address, similar to the example below

cat /etc/foundationdb/fdb.cluster
# DO NOT EDIT!
# This file is auto-generated, it is not to be edited by hand
description:cluster-id@192.168.0.10:4500
```

### Add the other FoundationDB nodes to the cluster

Copy the cluster file from an existing node in the cluster to the corresponding path on the new node (overwrite it), then restart.

On `cluster-fdb2` and `cluster-fdb3`, run:

```shell
scp root@192.168.0.10:/etc/foundationdb/fdb.cluster /etc/foundationdb/fdb.cluster

systemctl restart foundationdb || service foundationdb restart
```

Check the cluster status to confirm that each machine has joined the cluster and that the process count is correct.

```shell
fdbcli --exec "status details"
```

Key output:

```shell
Cluster:
  FoundationDB processes - 6
  Zones                  - 3
  Machines               - 3
```

If a new node fails to join the cluster, it is usually because it was previously started with an old configuration. In that case, stop the service, clean the data directories, and rejoin:

```shell
systemctl stop foundationdb || service foundationdb stop

scp root@192.168.0.10:/etc/foundationdb/fdb.cluster /etc/foundationdb/fdb.cluster
chown foundationdb:foundationdb /etc/foundationdb/fdb.cluster
chmod 664 /etc/foundationdb/fdb.cluster
chmod 775 /etc/foundationdb

rm -rf /fdb1/foundationdb/data/4500/*
rm -rf /fdb2/foundationdb/data/4501/*

chown -R foundationdb:foundationdb /fdb1/foundationdb /fdb2/foundationdb

systemctl start foundationdb || service foundationdb start

ss -lntp | egrep '4500|4501'

# Check cluster status.
fdbcli --exec "status details"
```

### Add the coordinator servers

Switch the coordinator servers and add more coordinators to improve fault tolerance.

After all nodes have joined the cluster, run the following on any node (it’s recommended to use one process port per node as a coordinator, e.g., port 4500 on each node):

```shell
fdbcli
fdb> coordinators 192.168.0.10:4500 192.168.0.11:4500 192.168.0.12:4500
```

### Adjust the redundancy mode and storage engine

Run on any node.

```shell
fdbcli
fdb> configure storage_migration_type=aggressive
fdb> configure double ssd
fdb> status details
```

## Deploy SeaDB

### Download and modify `.env`

You should deploy the SeaDB service on a new node using Docker.

To deploy SeaDB with Docker, you need to download `.env`, `seadb.yml` and `fdb.cluster` in a directory (e.g., `/opt/seadb`):

```bash
mkdir /opt/seadb
cd /opt/seadb

wget -O .env https://manual.seaticket.ai/0.9/repo/docker/seadb/env
wget https://manual.seaticket.ai/0.9/repo/docker/seadb/seadb.yml
wget https://manual.seaticket.ai/0.9/repo/docker/seadb/fdb.cluster

vim .env
```

The following fields merit particular attention:

| Variable                        | Description                                                                                                   | Default Value                   |  
| ------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------- |  
| `SEADB_SERVER_ACCESS_TOEKN`                           | SEADB_SERVER_ACCESS_TOEKN, A random string with a length of no less than 32 characters is required for SeaTicket, which can be generated by using `pwgen -s 40 1` | (required) |  
| `SEADB_VOLUME`                | The volume directory of SeaDB data                                                                          | `/opt/seadb-data`             |
| `TIME_ZONE`                     | Time zone                                                                                                     | `UTC`                           |

Modify `fdb.cluster`, the content should copy from the `/etc/foundationdb/fdb.cluster` file in any FoundationDB node:

```bash
vim fdb.cluster
```

### Start SeaDB

Run the following command:

```bash
docker compose up -d

docker logs -f seadb
```

When you see the following log, it means that SeaDB is ready:

```log
seadb | seadb started
```
