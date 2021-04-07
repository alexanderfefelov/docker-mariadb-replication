# docker-mariadb-replication

```
---===     W O R K     I N     P R O G R E S S     ===---
```

Need MariaDB master-slave replication? One command to start master, one command to start each slave. What could be easier?

```
┌────────┐     ┌─────────┐
│        │     │         │
│ Master ├────>│ Slave 1 │
│        ├──┐  │         │
└────────┘  │  └─────────┘
           ...
            │  ┌─────────┐
            │  │         │
            └─>│ Slave N │
               │         │
               └─────────┘
```

## Environment variables

In addition to variables available from [official MariaDB image](https://hub.docker.com/_/mariadb), you may/must specify
some of the following variables for `docker run`.

For both master and slave:

| Name | Type | Mandatory | Default value | Description
| ---- | ---- | --------- | ------------- | -----------
| `SERVER_ID` | Number | Yes | No default value | [--server-id option](https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#server_id)
| `MODE` | String | Yes | No default value | `master` or `slave`
| `REPLICATOR_USERNAME` | String | No | `replicator` | User name of the account to use for connecting to the master
| `REPLICATOR_PASSWORD` | String | No | `password` | Password of the account to use for connecting to the master

For master only:

| Name | Type | Mandatory | Default value | Description
| ---- | ---- | --------- | ------------- | -----------
| `LOG_BIN` | String | No | `log-bin` | [--log-bin option](https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#log_bin)
| `BINLOG_FORMAT` | String | No | `MIXED` | [--binlog-format option](https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#binlog_format)

For slave only:

| Name | Type | Mandatory | Default value | Description
| ---- | ---- | --------- | ------------- | -----------
| `MASTER_HOST` | String | No | `mariadb-master.tld` | Host name (or IP address) of the master host
| `MASTER_PORT` | Number | No | `3306` | TCP/IP port  of the master host
| `RELAY_LOG` | String | No | `relay-bin` | [--relay-log option](https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#relay_log)

## Start master

Run something like

```bash
docker run \
  --name mariadb-master-42 \
  --detach \
  --env SERVER_ID=42 \
  --env MODE=master \
  --env MYSQL_ROOT_PASSWORD=password \
  --publish 10000:3306 \
  quay.io/alexanderfefelov/mariadb-replication \
&& docker run --rm --link mariadb-master-42:foobar martin/wait -p 3306 -t 300
```

and master with server ID 42 will be available at port 10000.

## Start slave(s)

After executing something like

```bash
docker run \
  --name mariadb-slave-24 \
  --detach \
  --env SERVER_ID=24 \
  --env MODE=slave \
  --env MASTER_HOST=192.168.1.123 \
  --env MASTER_PORT=10000 \
  --env MYSQL_ROOT_PASSWORD=password \
  --publish 12345:3306 \
  quay.io/alexanderfefelov/mariadb-replication \
&& docker run --rm --link mariadb-slave-24:foobar martin/wait -p 3306 -t 300 \
&& docker exec mariadb-slave-24 cp /read-only.cnf /etc/mysql/conf.d/ \
&& docker restart mariadb-slave-24 \
&& docker run --rm --link mariadb-slave-24:foobar martin/wait -p 3306 -t 300
```

read-only slave with server ID 24 will be available at port 12345.

## Check replication status

On master:

    docker exec --tty --interactive mariadb-master-42 \
      mysql --user=root --password --execute="SHOW SLAVE HOSTS \G"

On slave(s):

    docker exec --tty --interactive mariadb-slave-24 \
      mysql --user=root --password --execute="SHOW SLAVE STATUS \G"

## What's next?

- Check out [the official documentation](https://mariadb.com/kb/en/standard-replication/).
- See similar [solution for MySQL](https://github.com/alexanderfefelov/docker-mysql-replication).
