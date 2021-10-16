#!/bin/bash

# set e
#kubelet API
ufw allow 10250/tcp

#NodePort Services
ufw allow 30000:32767/tcp

# Border Gateway Protocol (BGP) port 179
sudo iptables -A INPUT -p tcp -m tcp --dport 179 -j ACCEPT