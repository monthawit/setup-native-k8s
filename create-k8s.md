# Prepare Hosts And Create Kubernetes Cluster



## Run Script to prepare host and install CRI-O, kubelet, kubectl

```bash
curl -s https://ct-gitlab.openlandscape.cloud/kubeworkshop1/basickubernetes-workshop-v1/-/raw/main/kubernetes-workshop/00-node-crio-prepare-ubuntu22-for-k8s1.29.1.sh | bash
```
## Change Host name 

```bash
hostnamectl set-hostname training01-worker-01
```

## apply hostname 

```bash
bash
```

## kubeadm reset to default 

```bash
kubeadm reset
```

## Create Kubernetes Cluster

```bash
kubeadm init --control-plane-endpoint=API-server-IP:6443 --upload-certs
```

### ตัวอย่าง 

* kubeadm init --control-plane-endpoint=milkylab-k8s-02.milkymonz.dedyn.io:6443 --upload-certs

* kubeadm init --control-plane-endpoint=192.168.234.50:6443 --upload-certs

## Join Master, Worker Node

* ให้นำ Command ที่ได้จากการ Install Master 1 ไป Run ในเครื่องที่ต้องการ Join

### ตัวอย่างการ Join Master Node 

```bash
You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join 192.168.234.30:6443 --token nz943q.t8n61zh2b9ny0lwb \
        --discovery-token-ca-cert-hash sha256:b47b9f5b58ae11cebfd254c81048cff8f92b6fabfb5e189002b4334fe644334a \
        --control-plane --certificate-key 19dc9bd8fe9b574eefacb2a8c15d2b3dc278df9d181d041f0db6267f5cb1d47e
```

### Setup KubeConfig เพื่อให้ Master Node สามารถ Connect API Server ได้ 

```bash 
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### ตัวอย่างการ Join worker Node

```bash
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.234.30:6443 --token nz943q.t8n61zh2b9ny0lwb \
        --discovery-token-ca-cert-hash sha256:b47b9f5b58ae11cebfd254c81048cff8f92b6fabfb5e189002b4334fe644334a
```

## ตรวจสอบ Cluster 

### Check node Status 

```bash
kubectl get node
```

### Check POD Status 

```bash
kubectl get pod -A
```

## Navigation

* Previous: [Kubernetes Workshop Outline](/doc/kubernetes/00-kubernetes-workshop.md)
* Next: [Installing Addons](/doc/kubernetes/02-installing-addons.md)
* [Home](/README.md)

### ----- Link -----
* [Kubernetes Workshop Overview](/doc/kubernetes/00-kubernetes-workshop.md)
* [Create Kubernetes Cluster](/doc/kubernetes/01-create-k8s-cluster.md)
* [Installing Addons](/doc/kubernetes/02-installing-addons.md)
* [Kubernetes Command](/doc/kubernetes/03-kube-command.md)
* [Kubernetes YAML](/doc/kubernetes/04-kube-yaml.md)
* [Static Pod And Control Plane](/doc/kubernetes/05-static-pod-and-kube-controlplane.md)
* [Kubernetes Pod And Deployment](/doc/kubernetes/06-kube-pod-deployment.md)
* [Kubernetes Label And Selector](/doc/kubernetes/07-label-selector.md)
* [Kubernetes Services](/doc/kubernetes/08-kubernetes-service.md)
* [Kubernetes Ingress](/doc/kubernetes/09-kubernetes-ingress.md)
* [Kubernetes Ingress with Cert-manager](/doc/kubernetes/10-kubernetes-cert-manager.md)
* [Kubernetes Storage And Volume](/doc/kubernetes/11-kubernetes-storage-volume.md)
* [Kubernetes Secret](/doc/kubernetes/12-kubernetes-secret.md)
* [Kubernetes Configmap](/doc/kubernetes/13-kubernetes-configmap.md)
* [Kubernetes Environment Variable](/doc/kubernetes/14-kubernetes-env-variable.md)
* [Kubernetes Pod Autoscale](/doc/kubernetes/15-kubernetes-pod-autoscale.md)
* [Kubernetes-bashboard](/doc/kubernetes/16-kubernetes-dashboard.md)
* [Helm](/doc/kubernetes/17-helm.md)
* [Managed Kubernetes](/doc/kubernetes/18-managed-kubernetes.md)
