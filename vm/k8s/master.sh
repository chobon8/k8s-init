#!/bin/bash
# @Auther Victor2Code

echo "Please make sure below requirements are met before proceed:"
echo "1. Each machine in cluster can reach Google cloud"
echo "2. Each machine in cluster with more than 2 CPUs/2GB Ram"
echo "3. Kernel version above or equal to 3.10(uname -r)"
echo -e "\n"
echo "And make sure below places have been modified accordingly:"
echo "1. /etc/hosts settings"
echo "2. iptables LAN IP range setting"
echo "3. (optional)minor version for Kubeadm/Kubectl/Kubelet"
echo "4. master ip in kubeadm.yml"
read -p "Proceed now?(y/n):" flag
if [[ $flag =~ [yY] ]];
then
echo "Starting now..."
else
exit 1
fi

### *****
### Please modify below section accordingly
### *****
cat >> /etc/hosts << EOF
192.168.30.200 master
192.168.30.201 node1
192.168.30.202 node2
EOF

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

echo -e "\033[43m *** [Step1] firewall setup *** \033[0m"
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service
sudo yum -y install iptables-services
sudo systemctl start iptables.service
sudo systemctl enable iptables.service
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 6443 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 2379:2380 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 10250:10252 -j ACCEPT
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 30000:32767 -j ACCEPT
### *****
### Please modify below section accordingly
### *****
iptables -I INPUT -d 192.168.0.0/16 -j ACCEPT
iptables -I INPUT -s 192.168.0.0/16 -j ACCEPT
service iptables save
sed -i '/-A FORWARD -j REJECT/s/^/#/g' /etc/sysconfig/iptables
sudo systemctl restart iptables

echo -e "\033[43m *** [Step2] install common tools *** \033[0m"
sudo yum -y install wget
sudo yum -y install vim
sudo yum -y install telnet telnet-server xinetd
sudo systemctl enable telnet.socket
sudo systemctl start telnet.socket
sudo systemctl enable xinetd
sudo systemctl start xinetd
sudo yum -y install net-tools
sudo yum -y install traceroute
sudo yum -y install lsof
sudo yum -y install sysstat
sudo yum -y install nc
sudo yum -y install tcpdump
sudo yum -y install tree
sudo yum -y install bind-utils
sudo yum -y install nmap
sudo yum -y install git
sudo yum -y install unzip
sudo yum -y install zip
sudo yum -y install sshpass

echo -e "\033[43m *** [Step3] adjust kernel parameters *** \033[0m"
setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf

echo -e "\033[43m *** [Step4] activate ipvs modules *** \033[0m"
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
sudo yum -y install ipvsadm
sudo yum -y install ipset

echo -e "\033[43m *** [Step5] install docker *** \033[0m"
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum install -y --setopt=obsoletes=0 docker-ce
systemctl start docker
systemctl enable docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl restart docker
docker info | grep Cgroup