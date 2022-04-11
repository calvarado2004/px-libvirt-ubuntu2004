POD=$(kubectl get pods -o wide -n kube-system -l name=portworx | tail -1 | awk '{print $1}')
kubectl exec -it pod/${POD} -n kube-system -- /opt/pwx/bin/pxctl status

