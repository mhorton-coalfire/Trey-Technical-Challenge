module "folders" {
  source    = "terraform-google-modules/folders/google"
  version   = "~> 2.0"

  parent    = "${var.parent_type}/${var.parent_id}"
  names     = var.folder_names
}
