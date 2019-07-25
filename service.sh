#!/bin/bash

set -eu

# LOCAL_DATA=$HOME/docker-mounts/rabbit-mq
LOCAL_DATA=RABBITMQ_DATA
NODE_INDEX=0

docker volume create $LOCAL_DATA 1> /dev/null || true
docker stop RABBIT_MQ_$NODE_INDEX && docker rm RABBIT_MQ_$NODE_INDEX || true;

# sudo rm -rf $LOCAL_DATA/lib || true
# sudo rm -rf $LOCAL_DATA/conf || true
# sudo rm -rf $LOCAL_DATA/config || true

# mkdir -p $LOCAL_DATA/lib || true
# mkdir -p $LOCAL_DATA/conf || true

# cp ./conf-initial/*.conf $LOCAL_DATA/conf/

RBHOST=node-$NODE_INDEX
RBHOSTQ=rabbit@$RBHOST

docker build --build-arg HOST=$RBHOST . -t rabbitmq-custom:3.7-management

docker run -d --hostname $RBHOST                                      \
    --name RABBIT_MQ_$NODE_INDEX                                            \
    -p "4369:4369"                                           \
    -p "5672:5672"                                           \
    -p "15672:15672"                                         \
    -p "25672:25672"                                         \
    -p "35198:35197"                                         \
    -v $LOCAL_DATA:/var/lib/rabbitmq \
    rabbitmq-custom:3.7-management

