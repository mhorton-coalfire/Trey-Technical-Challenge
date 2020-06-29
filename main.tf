provider "google" {
  project   = var.project_id
  region    = var.region_name
}

module "folders" {
  source      = "./Folders"

  folder_names  = ["management", "application"]
  parent_id     = "478509003713"
  parent_type   = "organizations"
}

module "network" {
  source           = "./Network"
  project_id       = var.project_id
  region_name      = var.region_name
}

module "redhat_instance" {
  source          = "./InstanceTemplates"

  template_name   = "redhat-instance-template"
  machine_type    = "n1-standard-2"

  disk_size       = "20"
  source_image    = "rhel-cloud/rhel-8"

  network_name    = module.network.network_name
  subnet_name     = module.network.subnets[0]
}

module "nginx_instance" {
  source          = "./InstanceTemplates"

  template_name   = "nginx-instance-template"
  machine_type    = "n1-standard-2"
  startup_script  = "apt-get update && apt-get install -y nginx"

  disk_size       = "20"
  source_image    = "rhel-cloud/rhel-8"

  network_name    = module.network.network_name
  subnet_name     = module.network.subnets[2]
}

resource "google_compute_instance_group_manager" "redhat" {
  name                = "redhat-servers"
  version {
    instance_template = module.redhat_instance.id
  }

  base_instance_name  = "redhat-server"
  zone                = var.default_zone
  target_size         = 1
}

resource "google_compute_instance_group_manager" "nginx" {
  name                = "nginx-servers"
  version {
    instance_template   = module.nginx_instance.id
  }

  base_instance_name  = "nginx-server"
  zone                = var.default_zone
  target_size         = 1
  named_port {
    name = "http"
    port = 80
  }
}

module "gce-lb-http" {
  source      = "GoogleCloudPlatform/lb-http/google"
  version     = "~> 4.1.0"
  project     = var.project_id

  name        = "nginx-group-lb"
  target_tags = ["http"]

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
          group                        = google_compute_instance_group_manager.nginx.self_link
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
