variable "compartment_ids" {
  type = map(string)
}

variable "subnet_ids" {
  type = map(string)
}

variable "region" {
  type = string
}

variable "linux_images" {
  type = map(map(string))
}

variable "instance_params" {
  description = "Placeholder for the parameters of the instances"
  type = map(object({
    ad                   = number
    shape                = string
    hostname             = string
    boot_volume_size     = number
    assign_public_ip     = bool
    preserve_boot_volume = bool
    compartment_name     = string
    subnet_name          = string
    freeform_tags        = map(string)
    block_vol_att_type   = string
    encrypt_in_transit   = bool
    fd                   = number
    image_version        = string
    ssh_private_key      = string
    script_tf_string     = string
    ocpus               = optional(number)
    memory_in_gbs       = optional(number)
  }))
}

variable "ssh_public_key" {
  type = string
}

variable "registry" {
  type = string
}