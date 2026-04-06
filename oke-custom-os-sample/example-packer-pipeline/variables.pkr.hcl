# Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Packer Variables

variable "compartment_ocid" {
  type = string
}

variable "subnet_ocid" {
  type = string
}

variable "base_image_ocid" {
  type = string
}
