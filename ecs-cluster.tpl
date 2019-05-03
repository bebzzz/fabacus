#!/bin/bash
mkdir -p /etc/ecs
touch /etc/ecs/ecs.config
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config

yum update -y
yum install -y docker
service docker start
usermod -a -G docker $USER
yum install ecs-init -y
sudo start ecs