# Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Packer Image Pipeline

packer {
  required_plugins {
    oracle = {
      source  = "github.com/hashicorp/oracle"
      version = ">= 1.0.3"
    }
  }
}

source "oracle-oci" "example" {
  availability_domain = "RiYU:EU-FRANKFURT-1-AD-1"
  compartment_ocid    = var.compartment_ocid
  base_image_ocid     = var.base_image_ocid
  image_name          = "oke-node-{{timestamp}}"
  shape               = "VM.Standard.E5.Flex"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 12
  }  
  ssh_username        = "rocky"
  subnet_ocid         = var.subnet_ocid
  image_launch_mode = "NATIVE"
  skip_create_image = false

  metadata = {
    user_data = base64encode(file("cloud-init.sh"))
  }
}

build {
  sources = ["source.oracle-oci.example"]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait"
    ]
  }
}
