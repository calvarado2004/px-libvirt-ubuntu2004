#!/bin/bash
set -e

kubeadm config images pull --kubernetes-version=v${KUBERNETES_VERSION}

kubeadm init --cri-socket /var/run/crio/crio.sock --pod-network-cidr=10.244.0.0/16 \
        --token ${TOKEN} --apiserver-advertise-address=${MASTER_IP} --kubernetes-version=v${KUBERNETES_VERSION} --upload-certs --apiserver-cert-extra-sans=localhost,127.0.0.1,0.tcp.ngrok.io

DROPLET_IP_ADDRESS=$(ip addr show dev eth0 | awk 'match($0,/inet (([0-9]|\.)+).* scope global eth0$/,a) { print a[1]; exit }')

echo $DROPLET_IP_ADDRESS

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$DROPLET_IP_ADDRESS\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload

echo "serverTLSBootstrap: true" >> /var/lib/kubelet/config.yaml 

systemctl start kubelet
systemctl enable kubelet

KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f /tmp/calico.yml

#sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf taint node master.calvarado04.com node-role.kubernetes.io/master:NoSchedule-
