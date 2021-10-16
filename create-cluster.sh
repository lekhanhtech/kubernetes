#!/bin/bash

# Init cluster
sudo kubeadm init --config ./kubeadm/kubeadm-config.yaml
# sudo kubeadm init

# kube config
if [ -d $HOME/.kube ]; then
    sudo rm -rf $HOME/.kube
fi
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u username):$(id -g usergroup) $HOME/.kube/config

# Install network plugin
# Calico, reference: https://docs.projectcalico.org/getting-started/kubernetes/quickstart
kubectl apply -f ./calico/calico.yaml
# Or Kube-router, reference: https://github.com/cloudnativelabs/kube-router/blob/master/docs/kubeadm.md
# sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter-all-features.yaml

#patch
# kubectl patch node master-node -p '{"spec":{"podCIDR":"10.100.0.1/16"}}'
kubectl taint nodes --all node-role.kubernetes.io/master-

# Metrics server:
# Reference: https://github.com/kubernetes-sigs/metrics-server
kubectl apply -f ./metrics-server/components.yaml

# NGINX Ingress Controller
# Reference: https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
#1. Configure RBAC
# Create a namespace and a service account for the Ingress controller:
kubectl apply -f ./nginx-ingress/deployments/common/ns-and-sa.yaml
# Create a cluster role and cluster role binding for the service account:
kubectl apply -f ./nginx-ingress/deployments/rbac/rbac.yaml
# (App Protect only) Create the App Protect role and role binding:
kubectl apply -f ./nginx-ingress/deployments/rbac/ap-rbac.yaml

# 2. Create Common Resources
# Create a secret with a TLS certificate and a key for the default server in NGINX:
kubectl apply -f ./nginx-ingress/deployments/common/default-server-secret.yaml
# Create a config map for customizing NGINX configuration:
kubectl apply -f ./nginx-ingress/deployments/common/nginx-config.yaml
# Create an IngressClass resource
kubectl apply -f ./nginx-ingress/deployments/common/ingress-class.yaml
# Create Custom Resources
kubectl apply -f ./nginx-ingress/deployments/common/crds/k8s.nginx.org_virtualservers.yaml
kubectl apply -f ./nginx-ingress/deployments/common/crds/k8s.nginx.org_virtualserverroutes.yaml
kubectl apply -f ./nginx-ingress/deployments/common/crds/k8s.nginx.org_transportservers.yaml
kubectl apply -f ./nginx-ingress/deployments/common/crds/k8s.nginx.org_policies.yaml
kubectl apply -f ./nginx-ingress/deployments/common/crds/k8s.nginx.org_globalconfigurations.yaml
kubectl apply -f ./nginx-ingress/deployments/common/crds/appprotect.f5.com_aplogconfs.yaml
kubectl apply -f ./nginx-ingress/deployments/common/crds/appprotect.f5.com_appolicies.yaml
kubectl apply -f ./nginx-ingress/deployments/common/crds/appprotect.f5.com_apusersigs.yaml

# 3. Deploy the Ingress Controller
# Run the Ingress Controller
kubectl apply -f ./nginx-ingress/deployments/deployment/nginx-ingress.yaml
# Check that the Ingress Controller is Running
kubectl get pods --namespace=nginx-ingress

# 4. Get Access to the Ingress Controller
# Create a Service for the Ingress Controller Pods
# Use a NodePort service
kubectl create -f ./nginx-ingress/deployments/service/nodeport.yaml

# Cer-manager
# reference: https://cert-manager.io/docs/installation/kubectl/
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.yaml
# reference: https://cert-manager.io/docs/concepts/issuer
kubectl apply -f ./nginx-ingress/cert-manager/cert-manager-issuers.yaml

# Dashboard
kubectl apply -f ./dashboard/kubernetes-dashboard.yaml
