#!/bin/bash

systemctl stop docker
yum list installed | grep docker

rpm -qa |grep docker
yum remove docker-ce \
docker-ce-cli \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine

rpm -qa |grep docker

rm -rf /var/lib/docker