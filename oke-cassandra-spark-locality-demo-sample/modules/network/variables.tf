// Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
// The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/oci-quickstart/oci-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
#variable "oci_service_gateway" {}
variable "VCN_CIDR" {}
variable "useExistingVcn" {}
variable "custom_vcn" {
  type    = list(string)
  default = [" "]
}

variable "vcn_dns_label" {}

variable "edge_cidr" {}
variable "private_cidr" {}

variable "myVcn" {}
variable "OKESubnet" {
  default = " "
}
variable "edgeSubnet" {
  default = " "
}

variable "service_port" {}
