# Index management

## Some commands

### Modify configurations rebuild.sh

```shell

export SEAQA_MYSQL_DB_HOST=xxx
export SEAQA_MYSQL_DB_PORT=3306
export SEAQA_MYSQL_DB_USER=xxx
export SEAQA_MYSQL_DB_PASSWORD=xxx
export SEAQA_MYSQL_DB_NAME=xxx

export SEASEARCH_URL=xxx
export SEASEARCH_TOKEN=xxx
...

```

### Rebuild connection index

```shell
cd /opt/seaqa-indexer/seaqa_indexer/index/script

./rebuild_index.sh --connection-id xx clear

./rebuild_index.sh --connection-id xx update

```

### Rebuild project index

```shell

cd /opt/seaqa-indexer/seaqa_indexer/index/script

./rebuild_index.sh --project-uuid xxx clear

./rebuild_index.sh --project-uuid xxx update


```
