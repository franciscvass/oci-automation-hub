locals {
  linux_instances = {
    for instance in oci_core_instance.this :
    instance.display_name => { "id" : instance.id, "ip" : instance.public_ip != "" ? instance.public_ip : instance.private_ip }
  }
  linux_ids = {
    for instance in oci_core_instance.this :
    instance.display_name => instance.id
  }

  linux_private_ips = {
    for instance in oci_core_instance.this :
    instance.display_name => instance.private_ip
  }


  all_instances   = merge(local.linux_ids /*,local.windows_ids*/)
  all_private_ips = merge(local.linux_private_ips /*, local.windows_private_ips*/)
}

output "linux_instances" {
  value = local.linux_instances
}

output "all_instances" {
  value = local.all_instances
}

output "all_private_ips" {
  value = local.all_private_ips
}
