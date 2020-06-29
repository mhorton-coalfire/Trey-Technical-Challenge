# 
# Set provider
# 
provider "google" {
  project   = var.project_id
  region    = var.region_name
}

#
# Create VPC network and subnets
# 
module "network" {
  source           = "./Network"
  project_id       = var.project_id
  region_name      = var.region_name
  network_name     = "cf-vpc"
}

#  
# Create instance template for Redhat instance
# 
module "redhat_instance" {
  source          = "./InstanceTemplates"

  template_name   = "redhat-instance-template"
  machine_type    = "n1-standard-2"
  tags            = ["ssh"]

  disk_size       = "20"
  source_image    = "rhel-cloud/rhel-8"

  network_name    = module.network.network_name
  subnet_name     = module.network.subnets[0]
}

##
## Create instance template for Nginx webserver
##
module "nginx_instance" {
  source          = "./InstanceTemplates"

  template_name   = "nginx-instance-template"
  machine_type    = "n1-standard-2"
  startup_script  = "sudo yum update && sudo yum install -y nginx"
  tags            = ["html", "ssh"]

  disk_size       = "20"
  source_image    = "rhel-cloud/rhel-8"
  
  network_name    = module.network.network_name
  subnet_name     = module.network.subnets[2]
}

##
## Initiate single instance on instance group from Redhat template
##
module "redhat_instances" {
  source = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 3.0"
  project_id = var.project_id

  instance_template = module.redhat_instance.id
  hostname = "redhat-server"
  region = var.region_name
  distribution_policy_zones = [var.default_zone]
  target_size = 1
}

##
## Initiate single instance on instance group from Nginx template
##
module "nginx_group" {
  source = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 3.0"
  project_id = var.project_id

  instance_template = module.nginx_instance.id
  hostname = "nginx-server"
  region = var.region_name
  distribution_policy_zones = [var.default_zone]
  target_size = 1
  named_ports = [
    {
      name = "http"
      port = 80
    }
  ]
}

##
## Create Http(s) Load Balancer
##
module "gce-lb-http" {
  source      = "GoogleCloudPlatform/lb-http/google"
  version     = "~> 4.1.0"
  project     = var.project_id

  name        = "nginx-group-lb"
  target_tags = ["http"]
  firewall_networks = [module.network.network_name]
  firewall_projects = [var.project_id]

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable      = false
        sample_rate = null
      }

      groups = [
        {
          group                        = module.nginx_group.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        }
      ]
    }
  }
}
