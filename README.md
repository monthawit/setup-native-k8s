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
