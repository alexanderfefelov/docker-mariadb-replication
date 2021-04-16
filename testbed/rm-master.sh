#!/usr/bin/env bash

set -e

[ $UID -eq 0 ] || exec sudo bash "$0" "$@"

. settings.sh

docker container rm --force --volumes $MASTER_CONTAINER_NAME
