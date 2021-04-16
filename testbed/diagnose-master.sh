#!/usr/bin/env bash

set -e

[ $UID -eq 0 ] || exec sudo bash "$0" "$@"

. settings.sh

readonly QUERIES='
SHOW MASTER STATUS \G
SHOW SLAVE HOSTS \G
'
IFS=$'\n'
for query in $QUERIES; do
  echo -e "\n$query\n"
  docker exec --tty --interactive $MASTER_CONTAINER_NAME mysql --user=root --password=$ROOT_PASSWORD --execute=$query
done
