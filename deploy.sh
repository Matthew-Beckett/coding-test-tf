#!/bin/bash
amazon-linux-extras install docker
yum install -y git
service docker start
usermod -a -G docker ec2-user
chkconfig docker on
docker run --rm -d -p 80:80 --name helloworld nginxdemos/hello
docker ps
curl localhost:80