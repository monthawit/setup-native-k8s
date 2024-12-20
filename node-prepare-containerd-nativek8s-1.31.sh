#!/bin/bash

### Disable SWAP ###

sudo swapoff -a
sudo rm /swap.img
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

### Config OS Network Mofule ###

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system


sudo apt update -y && sudo apt upgrade -y

### install Containerd ###

set -e

# Function to print messages
log() {
  echo -e "\e[1;32m[INFO]\e[0m $1"
}

log "Updating system packages"
sudo apt update && sudo apt upgrade -y

log "Installing required dependencies"
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

log "Adding Docker GPG key"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

log "Adding Docker repository"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

log "Updating package sources"
sudo apt update

log "Installing containerd"
sudo apt install -y containerd.io

log "Configuring containerd"
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

log "Setting SystemdCgroup to true in containerd configuration"
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

log "Restarting and enabling containerd service"
sudo systemctl restart containerd
sudo systemctl enable containerd

log "Verifying containerd installation"
sudo systemctl status containerd --no-pager
containerd --version

log "Containerd installation completed successfully"

### install containerd tools for CLI ###

wget https://github.com/containerd/nerdctl/releases/download/v2.0.2/nerdctl-2.0.2-linux-amd64.tar.gz
tar -zxvf nerdctl-2.0.2-linux-amd64.tar.gz -C /usr/local/bin/
sudo chmod +x /usr/local/bin/nerdctl



### install storage Client ####
sudo apt update -y
apt-get install open-iscsi -y
apt-get install nfs-common -y

############# Nmon For Monitoring ########

apt install nmon -y


############# net-tools ################

apt install net-tools -y

############### Nginx for API LB #######

#sudo apt update -y
#sudo apt install nginx -y

#systemctl enable nginx 
#systemctl start nginx
#systemctl status nginx

##### install HELM ######

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

####################################################


### create dir key for ubuntu older than 22.04 ####

sudo mkdir -m 755 /etc/apt/keyrings

####################################################

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg


curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg


# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

#fix version. please insert version number
#sudo apt-get install -y kubelet=1.28.2-00 kubeadm=1.28.2-00 kubectl=1.28.2-00
#sudo apt-mark hold kubelet=1.28.2-00 kubeadm=1.28.2-00 kubectl=1.28.2-00


# install bash-completion
sudo apt-get install bash-completion -y

# Add the completion script to your .bashrc file
echo 'source /etc/bash_completion' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc

# Apply changes
source ~/.bashrc

