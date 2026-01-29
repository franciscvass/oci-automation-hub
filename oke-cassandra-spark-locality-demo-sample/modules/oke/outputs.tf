// Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
// The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

locals {
  cluster_id  = var.create_new_oke_cluster ? oci_containerengine_cluster.oke_dl_cluster[0].id : var.existing_oke_cluster_id
  nodepool_id = oci_containerengine_node_pool.dl_node_pool.id
}


output "cluster_id" {
  value = local.cluster_id
}

output "nodepool_id" {
  value = local.nodepool_id
}

