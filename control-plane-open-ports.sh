#!/bin/bash

# set e
#Kubernetes API server
ufw allow 6443/tcp
ufw allow 64430:64439/tcp

#etcd server client API
ufw allow 2379:2380/tcp

#kubelet API
ufw allow 10250/tcp

#kube-scheduler
ufw allow 10251/tcp

#kube-controller-manager
ufw allow 10250/tcp

#docker
ufw allow out on docker0 from 172.17.0.0/16

# Border Gateway Protocol (BGP) port 179
sudo iptables -A INPUT -p tcp -m tcp --dport 179 -j ACCEPT