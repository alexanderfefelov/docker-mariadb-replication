configure_server_id() {
  cat > /etc/mysql/conf.d/server-id.cnf << EOF
[mysqld]

# https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#server_id
server-id=$SERVER_ID
EOF
}

configure_log_bin() {
  cat > /etc/mysql/conf.d/log-bin.cnf << EOF
[mysqld]

# https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#log_bin
log-bin=$LOG_BIN

# https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#binlog_format
binlog-format=$BINLOG_FORMAT
EOF
}

configure_relay_log() {
  cat > /etc/mysql/conf.d/relay-log.cnf << EOF
[mysqld]

# https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#relay_log
relay-log=$RELAY_LOG
EOF
}

create_replication_account() {
  echo Creating replication account...
  mysql --user=root --password=$MYSQL_ROOT_PASSWORD --execute="
    CREATE USER '$REPLICATOR_USERNAME'@'%' IDENTIFIED VIA mysql_native_password USING password('$REPLICATOR_PASSWORD');
    GRANT REPLICATION SLAVE, BINLOG MONITOR ON *.* TO '$REPLICATOR_USERNAME'@'%';
  "
  echo ...replication account created
}

connect_slave_to_master() {
  echo Connecting slave to master...
  mysql --user=root --password=$MYSQL_ROOT_PASSWORD --execute="
    CHANGE MASTER TO
      MASTER_HOST='$MASTER_HOST',
      MASTER_PORT=$MASTER_PORT,
      MASTER_USER='$REPLICATOR_USERNAME',
      MASTER_PASSWORD='$REPLICATOR_PASSWORD',
      MASTER_USE_GTID = current_pos; -- https://mariadb.com/kb/en/gtid/#using-current_pos-vs-slave_pos
  "
  echo ...slave connected to master
}

start_slave() {
  echo Starting slave...
  mysql --user=root --password=$MYSQL_ROOT_PASSWORD --execute="
    START SLAVE;
  "
  echo ...slave started
}

prepare_master() {
  echo Preparing master...
  cp /initdb-master.sh /docker-entrypoint-initdb.d/
  configure_server_id
  configure_log_bin
  echo ...master prepared
}

prepare_slave() {
  echo Preparing slave...
  cp /initdb-slave.sh /docker-entrypoint-initdb.d/
  configure_server_id
  configure_relay_log
  echo ...slave prepared
}
