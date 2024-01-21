
![](./logo.jpeg)

markdown
Copy code
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

2. Install Multipass using Homebrew:

```sh
brew install --cask multipass

3. Download the script setup-k3s-cilium.sh from the repository.

```sh
4. Make the script executable:

    chmod +x setup-k3s-cilium.sh

5. Run the script:

   ./setup-k3s-cilium.sh

The script will perform the following actions:

Create a k3s leader and follower nodes using Multipass.
Install and configure k3s on these nodes.
Set up Cilium as the CNI plugin.
Configure kubectl to interact with the cluster.
```sh
6. Post-installation
After the script completes, you can use kubectl from your local machine to interact with your k3s cluster. The Cilium CLI is also available for managing network policies and other Cilium-specific configurations.


Troubleshooting
If you encounter any issues during the installation, check the following:

Ensure Multipass VMs are running correctly.
Verify if k3s and Cilium services are up and running.
Check the logs for any error messages.
Contributing
Contributions to the script are welcome! Please feel free to submit pull requests or open issues for any enhancements or fixes.

License
MIT License

Acknowledgments
This script was created to simplify the setup of a k3s cluster with Cilium on macOS environments. Thanks to the developers of k3s, Cilium, and Multipass for their fantastic tools.
