output "network_name" {
  value = module.vpc.network_name
}

output "subnets" {
  value = module.vpc.subnets_names
}
