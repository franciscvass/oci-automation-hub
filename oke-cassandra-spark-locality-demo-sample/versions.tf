// Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
// The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
provider "oci" {
  region       = var.region
  tenancy_ocid = var.tenancy_ocid

  # Only include these if running via CLI (i.e., not in Resource Manager)
  user_ocid        = var.user_ocid != "" ? var.user_ocid : null
  fingerprint      = var.fingerprint != "" ? var.fingerprint : null
  private_key_path = var.private_key_path != "" ? var.private_key_path : null
}


