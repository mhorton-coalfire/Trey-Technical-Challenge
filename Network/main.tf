module "vpc" {
  source            = "terraform-google-modules/network/google"
  version           = "~> 2.4"

  project_id        = var.project_id
  network_name      = "example-vpc"
  routing_mode      = "GLOBAL"

  subnets           = [
    {
      subnet_name   = "sub1"
      subnet_ip     = "10.0.0.0/24"
      subnet_region = var.region_name
    },
    {
      subnet_name   = "sub2"
      subnet_ip     = "10.0.1.0/24"
      subnet_region = var.region_name
    },
    {
      subnet_name   = "sub3"
      subnet_ip     = "10.0.2.0/24"
      subnet_region = var.region_name
    },
    {
      subnet_name   = "sub4"
      subnet_ip     = "10.0.3.0/24"
      subnet_region = var.region_name
    }
  ]
}
