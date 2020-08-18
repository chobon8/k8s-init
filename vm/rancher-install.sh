# Rancher安装

docker run -d --restart=unless-stopped -p 8080:80 -p 8443:443 rancher/rancher

# Rancher清除k8s缓存
# Error Message: [etcd] Failed to bring up Etcd Plane: [etcd] Etcd Cluster is not healthy
# Url: https://github.com/rancher/rancher/issues/19882

docker rm -f $(sudo docker ps -aq);
docker volume rm $(sudo docker volume ls -q);

rm -rf /etc/ceph \
/etc/cni \
/etc/kubernetes \
/opt/cni \
/opt/rke \
/run/secrets/kubernetes.io \
/run/calico \
/run/flannel \
/var/lib/calico \
/var/lib/etcd \
/var/lib/cni \
/var/lib/kubelet \
/var/lib/rancher \
/var/log/containers \
/var/log/pods \
/var/run/calico

rm -rf /var/lib/kubelet/* 
rm -rf /etc/kubernetes/*
rm -rf /etc/cni/*
rm -rf /var/lib/rancher/*
rm -rf /var/lib/etcd/*
rm -rf /var/lib/cni/*
rm -rf /opt/cni/*


for mount in $(mount | grep tmpfs | grep '/var/lib/kubelet' | awk '{ print $3 }') /var/lib/kubelet /var/lib/rancher; do umount $mount; done

rm -f /var/lib/containerd/io.containerd.metadata.v1.bolt/meta.db
sudo systemctl restart containerd
sudo systemctl restart docker

IPTABLES="/sbin/iptables"
cat /proc/net/ip_tables_names | while read table; do
  $IPTABLES -t $table -L -n | while read c chain rest; do
      if test "X$c" = "XChain" ; then
        $IPTABLES -t $table -F $chain
      fi
  done
  $IPTABLES -t $table -X
done