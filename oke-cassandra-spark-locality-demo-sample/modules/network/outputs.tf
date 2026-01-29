// Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
// The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

output "vcn-id" {
  value = var.useExistingVcn ? var.myVcn : oci_core_vcn.dl_vcn.0.id
}

output "private-id" {
  value = var.useExistingVcn ? var.OKESubnet : oci_core_subnet.private.0.id
}

output "edge-id" {
  value = var.useExistingVcn ? var.edgeSubnet : oci_core_subnet.edge.0.id
}


