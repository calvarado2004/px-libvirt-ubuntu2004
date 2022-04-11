#!/bin/bash
set -e

cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.121.100 master.calvarado04.com
192.168.121.200 worker0.calvarado04.com
192.168.121.201 worker1.calvarado04.com
192.168.121.202 worker2.calvarado04.com
EOF

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
# Add Cri-o repo
OS="xUbuntu_20.04"
VERSION=1.23
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -

apt update 
apt-get install -y apt-transport-https ca-certificates curl jq cri-o cri-o-runc linux-headers-$(uname -r) gcc cloud-guest-utils xfsprogs dbus nfs-common rpcbind nfs-kernel-server

modprobe overlay
modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-arptables = 1
net.ipv4.conf.all.rp_filter         = 0
net.netfilter.nf_conntrack_max      = 1000000
EOF

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

#Disable SWAP
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

apt-get install -y kubelet=${KUBERNETES_VERSION}-00 kubeadm=${KUBERNETES_VERSION}-00 kubectl=${KUBERNETES_VERSION}-00

apt-mark hold kubelet kubeadm kubectl

# Update CRI-O CIDR subnet
sed -i 's/10.85.0.0/10.244.0.0/g' /etc/cni/net.d/100-crio-bridge.conf

hostnamectl set-hostname $(hostname).calvarado04.com

# Start and enable Service

sysctl --system
systemctl daemon-reload

systemctl start crio
systemctl enable crio
systemctl status crio

systemctl enable kubelet
systemctl start kubelet


curl -L https://github.com/projectcalico/calico/releases/download/v3.22.1/calicoctl-linux-amd64 -o calicoctl

chmod 755 calicoctl 
