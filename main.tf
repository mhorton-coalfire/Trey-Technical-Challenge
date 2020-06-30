# 
# Set provider
# 
provider "google" {
  region    = var.region_name
}

#
# Create folders
#
module "management_folder" {
  source          = "./Folders"
  name            = "Management"
  organization_id = var.organization_id
}

module "application_folder" {
  source          = "./Folders"
  name            = "Application"
  organization_id = var.organization_id
}

#
# Create Management project
# 
module "management_project" {
  source              = "./Projects"
  name                = "management-project"
  folder_id           = module.management_folder.name
  organization_id     = var.organization_id
  billing_account_id  = var.billing_account_id
}

#
# Create VPC network and subnets
# 
module "network" {
  source           = "./Network"
  project_id       = module.management_project.id
  region_name      = var.region_name
  network_name     = "cf-vpc"
}

#
# Create Appliation project
#
module "application_project" {
  source      = "terraform-google-modules/project-factory/google//modules/shared_vpc"
  version     = "~> 8.0"

  name                = "application-project"
  random_project_id   = true
  folder_id           = module.application_folder.name
  org_id              = var.organization_id
  billing_account     = var.billing_account_id
  shared_vpc_enabled  = true
  
  shared_vpc          = module.network.project_id
  shared_vpc_subnets  = module.network.subnets_self_links

  disable_services_on_destroy = false
}

#  
# Create instance template for Redhat instance
# 
module "redhat_instance" {
  source          = "./InstanceTemplates"
  project_id        = module.application_project.project_id

  template_name   = "redhat-instance-template"
  machine_type    = "n1-standard-2"
  tags            = ["ssh"]

  disk_size       = "20"
  source_image    = "rhel-cloud/rhel-8"

  network_name    = module.network.network_name
  subnet_name     = module.network.subnets[0]
  vpc_project     = module.network.project_id
}

##
## Create instance template for Nginx webserver
##
module "nginx_instance" {
  source          = "./InstanceTemplates"
  project_id         = module.application_project.project_id

  template_name   = "nginx-instance-template"
  machine_type    = "n1-standard-2"
  startup_script  = "#! /bin/bash\nyum update\nyum install -y nginx\nservice nginx start"
  tags            = ["http-server", "ssh"]

  disk_size       = "20"
  source_image    = "rhel-cloud/rhel-8"
  
  network_name    = module.network.network_name
  subnet_name     = module.network.subnets[2]
  vpc_project     = module.network.project_id
}

##
## Initiate single instance on instance group from Redhat template
##
module "redhat_instances" {
  source = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 3.0"
  project_id = module.application_project.project_id

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
  project_id = module.application_project.project_id

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
  project     = module.application_project.project_id

  name        = "nginx-group-lb"
  target_tags = ["http"]
  firewall_networks = [module.network.network_name]
  firewall_projects = [module.management_project.id]

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
