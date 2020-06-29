resource "google_compute_instance_template" "default" {
  name            = var.template_name
  machine_type    = var.machine_type
  metadata_startup_script = var.startup_script

  disk {
    disk_size_gb  = var.disk_size
    source_image  = var.source_image
    auto_delete   = var.auto_delete
    boot          = true
  }

  network_interface {
    network       = var.network_name
    subnetwork    = var.subnet_name
  }
}
