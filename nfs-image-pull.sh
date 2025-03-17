#!/bin/bash

set -e

echo "Detecting OS type..."

# Detect OS
if [ -f /etc/debian_version ]; then
    OS="debian"
    PACKAGE_MANAGER="apt-get"
elif [ -f /etc/redhat-release ]; then
    OS="rhel"
    PACKAGE_MANAGER="yum"
else
    echo "Unsupported OS. Only Debian-based or RHEL-based systems are supported."
    exit 1
fi

echo "OS detected: $OS"

# Function to check and install package if missing
install_package() {
    PACKAGE=$1
    if ! command -v $PACKAGE &>/dev/null; then
        echo "Installing $PACKAGE..."
        if [ "$OS" = "debian" ]; then
            sudo $PACKAGE_MANAGER update -y
            sudo $PACKAGE_MANAGER install -y $PACKAGE
        else
            sudo $PACKAGE_MANAGER install -y $PACKAGE
        fi
    else
        echo "$PACKAGE is already installed."
    fi
}

# Install necessary tools
install_package wget
install_package curl
install_package git

# Install Docker
if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    if [ "$OS" = "debian" ]; then
        sudo $PACKAGE_MANAGER update -y
        sudo $PACKAGE_MANAGER install -y apt-transport-https ca-certificates gnupg
        curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo $PACKAGE_MANAGER update -y
        sudo $PACKAGE_MANAGER install -y docker-ce docker-ce-cli containerd.io
    else
        sudo $PACKAGE_MANAGER install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo $PACKAGE_MANAGER install -y docker-ce docker-ce-cli containerd.io
    fi
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker is already installed."
fi

# Clone the CSI NFS repo
if [ ! -d "csi-driver-nfs" ]; then
    echo "Cloning csi-driver-nfs repo..."
    git clone https://github.com/kubernetes-csi/csi-driver-nfs.git
else
    echo "csi-driver-nfs repo already exists."
fi

cd csi-driver-nfs/deploy || { echo "Failed to enter deploy directory"; exit 1; }

# Find all images in YAMLs
echo "Finding all image references in YAML files..."


grep -hoP 'image:\s*\K\S+' *.yaml | sort -u > images-list.txt

echo "Images Found"
cat images-list.txt

while read IMAGE; do
  echo "Pulling $IMAGE"
  docker pull "$IMAGE" || echo "Failed to pull $IMAGE"
done < images-list.txt

echo "All tasks completed successfully."
