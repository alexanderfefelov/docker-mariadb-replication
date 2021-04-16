#!/usr/bin/env bash

set -e

[ $UID -eq 0 ] || exec sudo bash "$0" "$@"

. settings.sh

readonly MASTER_IP_ADDRESS=${1:-$(ip route get 1.0.0.0 | awk '{ print $7 }')}
echo Master IP address to be used: $MASTER_IP_ADDRESS

docker run \
  --name $SLAVE_CONTAINER_NAME \
  --detach \
  --env SERVER_ID=$SLAVE_SERVER_ID \
  --env MODE=slave \
  --env MASTER_HOST=$MASTER_IP_ADDRESS \
  --env MASTER_PORT=$MASTER_PORT \
  --env MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD \
  --publish $SLAVE_PORT:3306 \
  $IMAGE_NAME
docker run --rm --link $SLAVE_CONTAINER_NAME:foobar martin/wait -p 3306 -t 300
docker exec $SLAVE_CONTAINER_NAME cp /read-only.cnf /etc/mysql/conf.d/
docker restart $SLAVE_CONTAINER_NAME
docker run --rm --link $SLAVE_CONTAINER_NAME:foobar martin/wait -p 3306 -t 300
