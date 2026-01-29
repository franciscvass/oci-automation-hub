// Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
// The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

output "bastion" {
  value = oci_core_instance.bastion
}

locals {

  private_ip = oci_core_instance.bastion.private_ip

  public_ip = oci_core_instance.bastion.public_ip

  instance_id = oci_core_instance.bastion.id
    
}

output "private_ip" {
  value = local.private_ip
}

output "public_ip" {
  value = local.public_ip
}

output "instance_id" {
  value = local.instance_id
}
