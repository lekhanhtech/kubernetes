#!/bin/bash

#  kubectl get no master-node -o yaml | grep spec -C 5
# sudo  netstat -lnp | grep 1025
sudo kubeadm reset
sudo ipvsadm --clear
sudo iptables -F KUBE-ROUTER-SERVICES && \
sudo iptables -F KUBE-ROUTER-FORWARD && \
sudo iptables -F KUBE-ROUTER-INPUT && \
sudo iptables -F KUBE-ROUTER-OUTPUT && \
sudo iptables -F KUBE-SERVICES && \
sudo iptables -F KUBE-FORWARD && \
sudo iptables -F KUBE-FIREWALL && \
sudo iptables -F KUBE-NWPLCY-DEFAULT && \
sudo iptables -F cali-OUTPUT && \
sudo iptables -F cali-INPUT && \
sudo iptables -F cali-FORWARD
sudo iptables --line-numbers -L INPUT | awk '/KUBE/{ print $1 }' | sort -r | while read num ; do sudo iptables -D INPUT ${num} ; done
sudo iptables --line-numbers -L OUTPUT | awk '/KUBE/{ print $1 }' | sort -r | while read num ; do sudo iptables -D OUTPUT ${num} ; done
sudo iptables --line-numbers -L FORWARD | awk '/KUBE/{ print $1 }' | sort -r | while read num ; do sudo iptables -D FORWARD ${num} ; done

if [ -f /etc/cni/net.d/caliso-kubeconfig ]; then
    sudo rm -f /etc/cni/net.d/caliso-kubeconfig
fi
if [ -f /etc/cni/net.d/10-caliso-conflist ]; then
    sudo rm -f /etc/cni/net.d/10-caliso-conflist
fi
if [ -f /etc/kubernetes/pki/ca.crt ]; then
    sudo rm -f /etc/kubernetes/pki/ca.crt
fi
# rm -rf ~/.kube/config
if [ -d $HOME/.kube ]; then
    rm -rf $HOME/.kube
fi
# docker rmi $(docker images -q 'k8s.gcr.io/kube-controller-manager' | uniq) --force && \
# docker rmi $(docker images -q 'k8s.gcr.io/kube-apiserver' | uniq) --force && \
# docker rmi $(docker images -q 'k8s.gcr.io/etcd' | uniq) --force && \
# docker rmi $(docker images -q 'k8s.gcr.io/coredns/coredns' | uniq) --force
# kubeadm config images pull
