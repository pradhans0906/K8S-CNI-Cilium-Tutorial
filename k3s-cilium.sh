#!/bin/bash

set -e

# Function to output error messages
function error {
    echo "Error: $1"
    exit 1
}

# Check if Homebrew and Multipass are installed
if ! command -v brew &> /dev/null; then
    error "Homebrew is not installed. Please install it first."
fi

if ! command -v multipass &> /dev/null; then
    echo "Installing Multipass..."
    brew install --cask multipass || error "Failed to install Multipass"
fi

# Create a VM for the k3s Leader (Control Plane)
echo "Creating k3s leader VM..."
multipass launch --name k3s-lead --memory 4G --disk 40G || error "Failed to create k3s leader VM"

# Install k3s on the leader node with Cilium-compatible options
echo "Installing k3s on leader VM..."
multipass exec k3s-lead -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--flannel-backend=none --disable-network-policy' sh -" || error "Failed to install k3s on leader"

echo "Adjusting permissions for kubeconfig..."
multipass exec k3s-lead -- sudo chmod 644 /etc/rancher/k3s/k3s.yaml || error "Failed to adjust permissions for kubeconfig"


# Mount BPF filesystem
echo "Mounting BPF filesystem..."
multipass exec k3s-lead -- sudo mount bpffs /sys/fs/bpf -t bpf || error "Failed to mount BPF filesystem"

# Retrieve the K3s node token and IP
echo "Retrieving k3s token and leader IP..."
TOKEN=$(multipass exec k3s-lead -- sudo cat /var/lib/rancher/k3s/server/node-token) || error "Failed to retrieve k3s token"
IP=$(multipass info k3s-lead | grep 'IPv4' | awk '{print $2}') || error "Failed to retrieve k3s leader IP"

# Create a follower node
echo "Creating k3s follower VM..."
multipass launch --name k3s-follower --memory 2G --disk 20G || error "Failed to create k3s follower VM"

# Install k3s on the follower node and join it to the cluster
echo "Installing k3s on follower VM and joining to the cluster..."
multipass exec k3s-follower -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=https://$IP:6443 K3S_TOKEN=$TOKEN sh -" || error "Failed to install k3s on follower"

# Set up kubectl
echo "Setting up kubectl..."
multipass exec k3s-lead -- sudo cat /etc/rancher/k3s/k3s.yaml > k3s-lead-config.yaml || error "Failed to retrieve k3s config"
sudo mv k3s-lead-config.yaml ~/.kube/config || error "Failed to move k3s config to .kube"
sudo chown $USER ~/.kube/config || error "Failed to change ownership of k3s config"
sudo chmod 755 ~/.kube/config || error "Failed to change permissions of k3s config"
sed -i '' "s/127.0.0.1/$IP/" ~/.kube/config || error "Failed to update kubectl config"

# Install Cilium CLI on the k3s leader node
echo "Installing Cilium CLI on the k3s leader node..."
CILIUM_CLI_INSTALL_SCRIPT=$(cat <<EOF
CILIUM_CLI_VERSION=\$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
[ "\$(uname -m)" = "aarch64" ] && CLI_ARCH=arm64
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/\${CILIUM_CLI_VERSION}/cilium-linux-\${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-\${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-\${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-\${CLI_ARCH}.tar.gz{,.sha256sum}
EOF
)
multipass exec k3s-lead -- bash -c "$CILIUM_CLI_INSTALL_SCRIPT" || error "Failed to install Cilium CLI on k3s leader node"

# Check if Cilium CLI is installed and in the PATH
echo "Checking if Cilium CLI is installed correctly..."
multipass exec k3s-lead -- bash -c "cilium version" || error "Cilium CLI is not installed correctly"

# Copy kubeconfig to user's home directory and adjust permissions
echo "Copying kubeconfig to user's home and adjusting permissions..."
KUBECONFIG_COPY_SCRIPT=$(cat <<EOF
sudo cp /etc/rancher/k3s/k3s.yaml \$HOME/k3s-kubeconfig
sudo chown ubuntu:ubuntu \$HOME/k3s-kubeconfig
sudo chmod 644 \$HOME/k3s-kubeconfig
EOF
)
multipass exec k3s-lead -- bash -c "$KUBECONFIG_COPY_SCRIPT" || error "Failed to copy and adjust kubeconfig"


# Install Cilium in the k3s cluster from the k3s leader node
echo "Installing Cilium in the k3s cluster from the k3s leader node..."
CILIUM_INSTALL_SCRIPT=$(cat <<EOF
export KUBECONFIG=\$HOME/k3s-kubeconfig
cilium install --version 1.14.6
EOF
)
multipass exec k3s-lead -- bash -c "$CILIUM_INSTALL_SCRIPT" || error "Failed to install Cilium in the k3s cluster"

echo "Waiting for Cilium to be ready..."
sleep 30

# Check Cilium readiness
CILIUM_CHECK_SCRIPT=$(cat <<EOF
export KUBECONFIG=\$HOME/k3s-kubeconfig
for i in {1..10}; do
    if cilium status | grep -q 'OK'; then
        echo "Cilium is ready."
        break
    fi
    echo "Waiting for Cilium to become ready..."
    sleep 10
done
EOF
)

multipass exec k3s-lead -- bash -c "$CILIUM_CHECK_SCRIPT" || error "Cilium is not ready"

# Verify the nodes and Cilium status from the k3s leader node
echo "Verifying the nodes and Cilium status in the cluster from the k3s leader node..."

# Verify the nodes and Cilium status from the k3s leader node
echo "Verifying the nodes and Cilium status in the cluster from the k3s leader node..."
CILIUM_STATUS_SCRIPT=$(cat <<EOF
export KUBECONFIG=\$HOME/k3s-kubeconfig
kubectl get nodes
cilium status
EOF
)
multipass exec k3s-lead -- bash -c "$CILIUM_STATUS_SCRIPT" || error "Failed to get node information or Cilium status from the k3s leader node"


echo "K3s cluster with Cilium setup is complete."