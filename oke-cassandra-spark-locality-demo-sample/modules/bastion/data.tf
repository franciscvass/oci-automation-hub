// Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
// The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
data "template_file" "ad_names" {
  template = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[(length(data.oci_identity_availability_domains.ads.availability_domains)-1)], "name")}"
}
