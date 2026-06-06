# RHCOS RHEL-10 Single Node OpenShift for Vera Rubin Testing

This repository contains automation scripts to create a bootable live ISO for Red Hat CoreOS (RHCOS) based on RHEL-10, specifically configured for Single Node OpenShift (SNO) deployment and NVIDIA GPU testing at Vera Rubin Observatory.

## Overview

The project automates the creation of a customized RHCOS live ISO that includes:
- OpenShift Container Platform 4.22.0-rc.2
- RHCOS build 10.2.20260423-0102 (RHEL-10 based)
- Container policy and DNS configuration via Butane
- Single Node OpenShift bootstrap configuration

## Prerequisites

Before running the setup script, ensure you have the following tools installed:

### Required Tools

1. **Butane** - Configuration translator for CoreOS systems
   ```bash
   # Download butane for your platform
   # https://github.com/coreos/butane/releases
   ```

2. **coreos-installer** - Tool for installing CoreOS
   ```bash
   # Download from:
   # https://github.com/coreos/coreos-installer/releases
   ```
## Quick Start

### 1. Create the Live ISO

Run the automated creation script:

```bash
./create.sh
```

This script will:
- Download the OpenShift installer (if not present)
- Download the RHCOS live ISO (if not present)
- Process Butane configuration files
- Generate the customized ISO with embedded ignition config

### 2. Deploy to Server

1. **Mount the ISO** to your target server using your preferred method:

2. **Boot from the ISO**

3. **Wait for bootstrap** - The system will:
   - Boot into RHCOS
   - Apply the ignition configuration
   - Bootstrap the OpenShift cluster
   - Automatically reboot when ready

### 3. Access the Cluster

After the bootstrap process completes and the server reboots:

1. **SSH into the server** (default CoreOS user)

2. **Set kubeconfig path**:
   ```bash
   export KUBECONFIG=/etc/kubernetes/bootstrap-secrets/kubeconfig
   ```

3. **Verify cluster access**:
   ```bash
   oc get nodes
   oc get pods -A
   ```

## Configuration Files

- **`create.sh`** - Main automation script for ISO creation
- **`container-policy.bu`** - Butane config for container policy settings
- **`dnsmasq.bu`** - Butane config for DNS services
- **`install-config.yaml.template`** - OpenShift installation configuration template
- **`local_manifests/`** - Custom manifests for cluster configuration


## Additional Resources

- [OpenShift Single Node Installation Guide](https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html-single/installing_on_a_single_node/index)
- [RHCOS Documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.21/html/architecture/architecture-rhcos)
- [Butane Configuration Specification](https://coreos.github.io/butane/)

