# nfs-airgap
Pull nfs-csi-driver Images for Airgapped Environment 


# CSI Driver NFS Air-Gapped Image Preparation Script

This script automates preparation of the Kubernetes **CSI NFS Driver** deployment in **air-gapped environments**. It performs the following steps:

1. Detects if the system is **Debian-based** or **RHEL-based**.
2. Installs required tools: `wget`, `curl`, `git`, and **Docker** (if not already installed).
3. Clones the official [CSI NFS Driver GitHub repository](https://github.com/kubernetes-csi/csi-driver-nfs.git).
4. Parses all image references from YAML manifests in the `deploy` folder.
5. Pulls all required Docker images.
6. Outputs all unique image references to a file.

---

## Prerequisites

- **Debian-based (Ubuntu, Debian)** or **RHEL-based (CentOS, RHEL, Oracle Linux)** OS.
- **sudo/root privileges**.
- **If you get permission error run following command**.

```bash
sudo usermod -aG docker $USER
```
- **Then Logout and Login bach to the terminal**.


---

## Usage

### 1. Download or copy the script:

```bash
git clone https://github.com/mandarveeam/nfs-airgap.git
cd nfs-airgap
chmod +x nfs-image-pull.sh
```


## License: 
This script is provided as-is, without any warranty or guarantee.
