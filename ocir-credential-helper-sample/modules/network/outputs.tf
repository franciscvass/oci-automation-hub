output "vcns" {
  value = {
    for vcn in oci_core_virtual_network.vcn :
    vcn.display_name => tomap({ "id" = vcn.id, "cidr" = vcn.cidr_block })
  }
}

output "subnets" {
  value = {
    for subnet in oci_core_subnet.subnets :
    subnet.display_name => tomap({ (subnet.id) = (subnet.cidr_block) })
  }
}

output "subnets_ids" {
  value = {
    for subnet in oci_core_subnet.subnets :
    subnet.display_name => subnet.id
  }
}
