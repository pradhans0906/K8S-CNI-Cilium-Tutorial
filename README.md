
![](./logo.jpeg)

# k3s Cluster Setup with Cilium

This script automates the process of setting up a lightweight Kubernetes (k3s) cluster with Cilium as the CNI (Container Network Interface). It is designed to run on macOS systems using Multipass for virtualization.

## Requirements

- macOS system
- [Homebrew](https://brew.sh/)
- [Multipass](https://multipass.run/)

## Installation

Before running the script, ensure Homebrew and Multipass are installed on your system.

1. Install Homebrew (if not already installed):

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
2. Install Multipass using Homebrew:
   ```sh
    brew install --cask multipass
```

Download the script setup-k3s-cilium.sh from the repository.

Make the script executable:

```sh
chmod +x setup-k3s-cilium.sh
Run the script:

./setup-k3s-cilium.sh
```

The script will perform the following actions:

Create a k3s leader and follower nodes using Multipass.
Install and configure k3s on these nodes.
Set up Cilium as the CNI plugin.
Configure kubectl to interact with the cluster.
