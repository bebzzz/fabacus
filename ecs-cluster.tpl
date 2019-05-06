#!/bin/bash
mkdir -p /etc/ecs
touch /etc/ecs/ecs.config
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config

sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod usermod -a -G docker $USER
sudo yum install ecs-init -y
sudo start ecs
