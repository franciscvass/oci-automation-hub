// Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
// The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

data "oci_core_services" "net_services" {
#  count = var.useExistingVcn ? 0 : 1
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

