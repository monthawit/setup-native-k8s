# setup-native-k8s



Install containerd  

https://github.com/containerd/containerd/blob/main/docs/getting-started.md 

* Prepare VM
## Update And Upgrade OS
```bash
apt update -y && apt upgrade -y
```

## install CRI-O and Tools
```bash
curl -s https://raw.githubusercontent.com/monthawit/setup-native-k8s/main/prepare-crio-node.sh | bash
```
## init Cluster 
```bash
kubeadm init --control-plane-endpoint=API-server-IP:6443 --upload-certs
```


# Install KubeSphere 

## Quick Start 

```bash
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/kubesphere-installer.yaml



kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/cluster-configuration.yaml

```
### check log 
```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f
```


## Manual 
## download yaml 

```bash
curl -L -O https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/cluster-configuration.yaml

curl -L -O https://github.com/kubesphere/ks-installer/releases/download/v3.4.1/kubesphere-installer.yaml


```
## install 

```bash
kubectl apply -f kubesphere-installer.yaml

kubectl apply -f cluster-configuration.yaml

```


## Check install LOG   

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f
```
