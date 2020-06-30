resource "google_folder" "default" {
  display_name = var.name
  parent       = "organizations/${var.organization_id}"
}