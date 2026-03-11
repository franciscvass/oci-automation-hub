output "vcns" {
  value = module.network.vcns
}

output "subnets" {
  value = module.network.subnets
}

output "linux_instances" {
  value = module.compute.linux_instances
}
