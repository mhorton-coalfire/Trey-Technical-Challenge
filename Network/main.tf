module "vpc" {
  source            = "terraform-google-modules/network/google"
  version           = "~> 2.4"

  project_id        = var.project_id
  network_name      = var.network_name
  routing_mode      = "GLOBAL"
  shared_vpc_host   = true

  subnets           = [
    {
      subnet_name   = "${var.network_name}-sub1"
      subnet_ip     = "10.0.0.0/24"
      subnet_region = var.region_name
      subnet_private_access = true
    },
    {
      subnet_name   = "${var.network_name}-sub2"
      subnet_ip     = "10.0.1.0/24"
      subnet_region = var.region_name
      subnet_private_access = true
    },
    {
      subnet_name   = "${var.network_name}-sub3"
      subnet_ip     = "10.0.2.0/24"
      subnet_region = var.region_name
      subnet_private_access = true
    },
    {
      subnet_name   = "${var.network_name}-sub4"
      subnet_ip     = "10.0.3.0/24"
      subnet_region = var.region_name
      subnet_private_access = true
    }
  ]

  routes            = [
    {
      name              = "egress-internet"
      description       = "route access to internet"
      destination_range        = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}

module "network-firewall" {
  source                    = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id                = var.project_id
  network                   = module.vpc.network_name

  admin_ranges              = ["10.0.0.0/12"]
}
