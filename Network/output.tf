output "project_id" {
  value = module.vpc.project_id
}

output "network_name" {
  value = module.vpc.network_name
}

output "subnets" {
  value = module.vpc.subnets_names
}

output "subnets_self_links" {
  value = module.vpc.subnets_self_links
}