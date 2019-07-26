#!/bin/bash
set -eu

echo "1 ============================================================================================================================="
sudo rabbitmq-plugins enable rabbitmq_management
echo "2 ============================================================================================================================="

sudo service rabbitmq-server stop && \
sudo service rabbitmq-server start

echo "3 ============================================================================================================================="

./init-users.sh

echo "4 ============================================================================================================================="

# Stop rabbit because main CMD in Dockerfile will start it direcly in order to see logs and output 
sudo service rabbitmq-server stop

#exec rabbitmq-server

exec "$@"