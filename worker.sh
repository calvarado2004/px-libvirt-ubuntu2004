#!/bin/bash
set -e

export PX_METADATA_NODE_LABEL="kubernetes.io/role=infra"

kubeadm join master.calvarado04.com:6443 --token ${TOKEN} --cri-socket /var/run/crio/crio.sock --discovery-token-unsafe-skip-ca-verification

DROPLET_IP_ADDRESS=$(ip addr show dev eth0 | awk 'match($0,/inet (([0-9]|\.)+).* scope global eth0$/,a) { print a[1]; exit }')

echo $DROPLET_IP_ADDRESS

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$DROPLET_IP_ADDRESS\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo "serverTLSBootstrap: true" >> /var/lib/kubelet/config.yaml

systemctl daemon-reload

systemctl start kubelet
systemctl enable kubelet

