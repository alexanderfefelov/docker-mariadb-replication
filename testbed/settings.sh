readonly IMAGE_NAME=quay.io/alexanderfefelov/mariadb-replication

readonly ROOT_PASSWORD=password

readonly MASTER_SERVER_ID=42
readonly MASTER_CONTAINER_NAME=mariadb-master-$MASTER_SERVER_ID
readonly MASTER_PORT=10000

readonly SLAVE_SERVER_ID=24
readonly SLAVE_CONTAINER_NAME=mariadb-slave-$SLAVE_SERVER_ID
readonly SLAVE_PORT=12345
