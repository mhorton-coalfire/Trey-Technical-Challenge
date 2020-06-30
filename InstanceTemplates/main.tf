resource "google_compute_instance_template" "default" {
  project                 = var.project_id
  name                    = var.template_name
  machine_type            = var.machine_type
  metadata_startup_script = var.startup_script
  tags                    = var.tags

  disk {
    disk_size_gb  = var.disk_size
    source_image  = var.source_image
    auto_delete   = var.auto_delete
    boot          = true
  }

  network_interface {
    access_config {
    }

    subnetwork    = var.subnet_name
    subnetwork_project = var.vpc_project
  }
}
