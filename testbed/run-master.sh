#!/usr/bin/env bash

set -e

[ $UID -eq 0 ] || exec sudo bash "$0" "$@"

. settings.sh

docker run \
  --name $MASTER_CONTAINER_NAME \
  --detach \
  --env SERVER_ID=$MASTER_SERVER_ID \
  --env MODE=master \
  --env MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD \
  --publish $MASTER_PORT:3306 \
  $IMAGE_NAME
docker run --rm --link $MASTER_CONTAINER_NAME:foobar martin/wait -p 3306 -t 300
