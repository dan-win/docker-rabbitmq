#!/bin/bash
echo "Creating user for CI"
rabbitmqctl  add_user ci ci
rabbitmqctl  set_user_tags ci administrator 
rabbitmqctl  set_permissions -p / ci ".*" ".*" ".*" 
