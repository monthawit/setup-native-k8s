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


sudo apt update -y
sudo apt -y upgrade

### install CRI-O ###
#apt install jq -y
#curl https://raw.githubusercontent.com/cri-o/packaging/main/get | bash
#sudo systemctl daemon-reload
#sudo systemctl enable crio --now crio
#crictl version

#KUBERNETES_VERSION=v1.32.2

### install CRI-O 1.32.2 ###

CRIO_VERSION=v1.34.1

apt-get update
apt-get install -y software-properties-common curl

curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list

apt-get update
apt-get install -y cri-o 

systemctl start crio.service
systemctl enable crio.service


### install cri tools ###

VERSION="v1.32.2"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

### install storage Client ####
sudo apt update -y
apt-get install open-iscsi -y
apt-get install nfs-common -y

############# net-tools ################

apt install net-tools -y

############### Nginx for API LB #######

#sudo apt update -y
#sudo apt install nginx -y

#systemctl enable nginx 
#systemctl start nginx
#systemctl status nginx

####################################################
### create dir key for ubuntu older than 22.04 ####

sudo mkdir -m 755 /etc/apt/keyrings

####################################################


sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


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
