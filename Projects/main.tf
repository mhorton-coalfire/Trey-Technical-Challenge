module "project-factory" {
  source      = "terraform-google-modules/project-factory/google"
  version     = "~> 8.0"

  name              = var.name
  random_project_id = true
  folder_id         = var.folder_id
  org_id            = var.organization_id

  billing_account   = var.billing_account_id
}
