#!/usr/bin/env bash

set -e

[ $UID -eq 0 ] || exec sudo bash "$0" "$@"

. settings.sh

readonly QUERIES='
SHOW SLAVE STATUS \G
'
IFS=$'\n'
for query in $QUERIES; do
  echo -e "\n$query\n"
  docker exec --tty --interactive $SLAVE_CONTAINER_NAME mysql --user=root --password=$ROOT_PASSWORD --execute=$query
done
