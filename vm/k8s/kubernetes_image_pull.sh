#!/bin/bash

tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://lo831hm4.mirror.aliyuncs.com"]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker

# pull images 

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.11
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.11
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.11
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.11
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1

# tag image

docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.11 k8s.gcr.io/kube-apiserver:v1.15.11
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.11 k8s.gcr.io/kube-controller-manager:v1.15.11
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.11 k8s.gcr.io/kube-scheduler:v1.15.11
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.11 k8s.gcr.io/kube-proxy:v1.15.11
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1

# 

