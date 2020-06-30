variable "default_zone" {
  type          = string
  description   = "Default zone for instances"
}

variable "billing_account_id" {
  type          = string
  description   = "GCP Billing Account ID"
}

variable "organization_id" {
  type          = string
  description   = "GCP Organization Id"
}

# variable "project_id" {
#   type          = string
#   description   = "GCP Project Id"
# }

variable "region_name" {
  type          = string
  description   = "GCP Region"
}
