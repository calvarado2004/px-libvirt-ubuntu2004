kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f 'https://install.portworx.com/?comp=pxoperator'

#kubectl --kubeconfig=/etc/kubernetes/admin.conf taint nodes master.calvarado04.com node-role.kubernetes.io/master=true:NoSchedule
