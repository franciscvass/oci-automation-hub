// Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
// The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

output "BASTION_PUBLIC_IP" { value = var.public_edge_node ? module.bastion.public_ip : "No public IP assigned" }

output "INFO" { value = "Data Locality with Cassandra and Spark" }
