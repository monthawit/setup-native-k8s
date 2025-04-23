#########################################################################
##################### CRIO and K8s Version ##############################
#########################################################################

KUBERNETES_VERSION=v1.32
CRIO_VERSION=v1.32

#########################################################################
################# Prepare Host And Network ##############################
#########################################################################

sudo swapoff -a
sudo rm /swap.img
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

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

#########################################################################
########################### Install CRIO ################################
#########################################################################

apt-get update
apt-get install -y software-properties-common curl

#### Add CRI-O Repo ######

curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list

##### install CRI-O #####

apt-get update
apt-get install -y cri-o kubelet kubeadm kubectl

#### Start And Enablre ########

systemctl start crio.service
systemctl enable crio.service
systemctl status crio.service

##### install CRI-Tools #######

sudo apt install cri-tools -y 

crictl version

############# install addon ################

sudo apt update -y
apt-get install open-iscsi -y
apt-get install nfs-common -y
apt install net-tools -y


####################################################
### create dir key for ubuntu older than 22.04 #####
####################################################

sudo mkdir -m 755 /etc/apt/keyrings

###########################################################
###### Install kubeadm, kubelet , kubectl #################
###########################################################

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

udo systemctl enable --now kubelet
