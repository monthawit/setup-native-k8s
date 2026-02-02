# setup-native-k8s

## Init Cluster 

kubeadm-config.yaml

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
clusterName: k8s102
controlPlaneEndpoint: "10.151.1.50:6443"
networking:
  podSubnet: "10.111.0.0/16"
```

init config file 

```bash
kubeadm init --config kubeadm-config.yaml --upload-certs
```

one command 

```bash

kubeadm init --control-plane-endpoint=master-node-ip-or-LoadBalancer-Virtual-ip:6443 --upload-certs

kubeadm init --control-plane-endpoint=master-node-ip-or-LoadBalancer-Virtual-ip:6443 --upload-certs  --pod-network-cidr=10.111.0.0/16 

kubeadm init --pod-network-cidr=10.0.0.0/16 --cluster-name cluster1

kubeadm init --pod-network-cidr=10.0.0.0/16 --cluster-name cluster1

```

## install cilium cidr 

### Check IP range 

```bash
# for service 
kubectl cluster-info dump | grep -m 1 service-cluster-ip-range

# for pod
kubectl -n kube-system get cm cilium-config -o yaml | grep -i 'cluster-pool-ipv4-cidr'

```


```bash
helm repo add cilium https://helm.cilium.io/
```

```bash
helm install cilium cilium/cilium --version 1.18.6 \
  --namespace kube-system \
  --set cluster.name=k8s102 \
  --set cluster.id=102 \
  --set ipam.operator.clusterPoolIPv4PodCIDRList='{10.111.0.0/16}' \
  --set ipv4NativeRoutingCIDR=10.111.0.0/16 \
  --set k8sServiceHost=10.151.1.41 \
  --set k8sServicePort=6443
```

## Prepare kubeconfig 
```bash
# 1. ย้ายไฟล์เก่าออกก่อนกันพลาด
mv config-all config-all.bak

# 2. สร้างโครงสร้างไฟล์ใหม่ (ดึงค่าจากไฟล์หลักของแต่ละเครื่อง)
# หมายเหตุ: เครื่อง k8s101 ต้องมีไฟล์ /etc/kubernetes/admin.conf อยู่ปกติ
cp /etc/kubernetes/admin.conf config-all

# 3. แก้ไขชื่อ Cluster/Context/User ในไฟล์ใหม่ให้สื่อสารง่าย
sed -i 's/kubernetes/cluster-101/g' config-all
sed -i 's/kubernetes-admin/user-101/g' config-all
sed -i 's/cluster-101-admin@cluster-101/k8s101/g' config-all

# รวมไฟล์ 101 และ 102 เข้าด้วยกันแบบถูก Syntax 100%
KUBECONFIG=config-all:temp102.yaml kubectl config view --flatten > config-merged.yaml

# นำไฟล์ที่รวมแล้วมาใช้งาน
mv config-merged.yaml config-all
export KUBECONFIG=$(pwd)/config-all

# ต้องเห็น 2 รายการ (k8s101 และ kubernetes-admin@k8s102)
kubectl config get-contexts

# ทดสอบดึง Nodes ของ cluster 102
kubectl get nodes --context kubernetes-admin@k8s102
```

## Setup Cluster Mesh 

```bash
kubectl config get-contexts

cilium clustermesh enable --context kubernetes-admin@k8s102 --service-type NodePort

cilium clustermesh enable --context kubernetes-admin@k8s102 --service-type LoadBalancer
```
example
```bash
kubectl get svc -n kube-system clustermesh-apiserver
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
clustermesh-apiserver   LoadBalancer   10.111.89.219   10.151.1.61   2379:32538/TCP   57s
```
### Connect Mesh
```bash
cilium clustermesh connect \
  --context kubernetes-admin@kubernetes \
  --destination-context kubernetes-admin@k8s102

cilium clustermesh connect \
  --context k8s101 \
  --destination-context kubernetes-admin@k8s102

cilium clustermesh status --context k8s101
```
### Debug list 

```bash
kubectl -n kube-system exec ds/cilium -- cilium-dbg service list
```

Install containerd  

https://github.com/containerd/containerd/blob/main/docs/getting-started.md 

* Prepare VM
## Update And Upgrade OS
```bash
apt update -y && apt upgrade -y
```

## install CRI-O and Tools
```bash
curl -s https://raw.githubusercontent.com/monthawit/setup-native-k8s/main/node-prepare-crio-nativek8s-1.30.2.sh | bash
```
Version 1.35 ContainerD 
```bash
curl -s https://raw.githubusercontent.com/monthawit/setup-native-k8s/refs/heads/main/node-prepare-containerd-nativek8s-1.35.sh | bash
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

# Install Nginx Ingress Controller 

https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters 

# Fix CRI-O Registry Shotname 

```bash 
vi /etc/crio/crio.conf.d/10-crio.conf
```
add 
```yaml
[crio.image]
short_name_mode = "disabled"
```
