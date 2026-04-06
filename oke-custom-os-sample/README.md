# OKE Custom Node OS
Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

## Objective
Enable a custom RHEL-based Linux Image ready for use with OKE Node Pools. 

## Prerequisites
* An OCI Tenancy
* Ability to create or modify an OKE cluster from the
  * OCI command line interface
  * Terraform
  * Cluster API

## Recommendation
* An [image building pipeline](example-packer-pipeline) to automate steps 1-4 below.

> [!NOTE]
> Please note, that Oracle, and specifically OKE, cannot offer official support for these scripts. You must provide your own validation and testing in non-production environments.

## High-level process
1.	Import a RHEL-Based Linux image to OCI https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/imageimportexport.htm
2.	Launch an instance from it to install the OKE node packages, OCI CLI and create OKE bootstrap script.
3.	Capture a “golden” image.
4.	Use that image to create an OKE managed node pool with the required bootstrap cloud-init.

## Step 1: 
* [Import the Rocky Linux image into OCI Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/data-migration.htm)
* [Import the Rocky Linux image as an OCI Custom Image from Object Storage](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/custom-images-import.htm)

## Step 2: 
* [Launch an instance from the imported image using the included cloud-init.sh script](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/launchinginstance.htm#shape-advanced-options)

This creates a compute instance using the imported custom image with the following cloud-init script while creating the instance. This script configures the required yum repository and installs the OKE node packages.

## Step 3:
Install OCI CLI & create OKE Bootstrap Script
* [SSH into the instance and install the OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__linux_and_unix)
* Create an `oke-install.sh` file with included script in directory `/etc/oke`
* Make `oke-install.sh` file executable 
```bash
sudo chmod +x /etc/oke/oke-install.sh
```
## Step 4: 
Create a new custom image from the configured instance
* [Creating a custom image](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/custom-images-create.htm)
This becomes your “OKE-ready” Rocky Linux image for managed node pools.

## Step 5: 
Create an OKE node pool using the latest custom image
Example using the OCI CLI command to create the node pool:
```bash
oci ce node-pool create --cluster-id <cluster-ocid> \
--compartment-id <compartment-ocid> \
--name "rocky-node-pool" \
--kubernetes-version v1.34.1 
--node-shape VM.Standard.E5.Flex \
--node-shape-config '{"ocpus": 2, "memoryInGbs": 8}' 
--size 3 \
--placement-configs '[{"availabilityDomain": "tslF:US-ASHBURN-AD-1", "subnetId": "<node-subnet-ocid>"}]' \
--pod-subnet-ids '["<pod-subnet-ocid>"]' --node-image-id <custom-image-ocid> \
--ssh-public-key "$(cat <public-key-path>)"  \
--node-metadata '{"user_data":"'"<base64-encoded cloud-init script>'"}'
```
Example Terraform Snippet:

```terraform
Here's the Terraform equivalent:
hclresource "oci_containerengine_node_pool" "rocky_node_pool" {
  cluster_id     = var.cluster_ocid
  compartment_id = var.compartment_ocid
  name           = "rocky-node-pool"
  kubernetes_version = "v1.34.1"

  node_shape = "VM.Standard.E5.Flex"

  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 8
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = var.custom_image_ocid
  }

  initial_node_labels {
    key   = "name"
    value = "rocky-node-pool"
  }

  ssh_public_key = file(var.public_key_path)

  node_config_details {
    size = 3

    placement_configs {
      availability_domain = "tslF:US-ASHBURN-AD-1"
      subnet_id           = var.node_subnet_ocid
    }

    node_pool_pod_network_option_details {
      cni_type    = "OCI_VCN_IP_NATIVE"
      pod_subnet_ids = [var.pod_subnet_ocid]
    }
  }

  node_metadata = {
    user_data = var.user_data_base64
  }
}
```
## Step 6
Validate the node pool has been created:
```
$ kubectl get nodes
NAME                   STATUS    ROLES   AGE      VERSION
10.0.100.12            Ready     node    1h       v1.34.0
10.0.100.143           Ready     node    1h       v1.34.0
10.0.100.56            Ready     node    1h       v1.34.0
