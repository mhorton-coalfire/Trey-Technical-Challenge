variable "template_name" {
  type          = string
  description   = "Template name"
}

variable "machine_type" {
  type          = string
  description   = "GCP machine type"
}

variable "startup_script" {
  type          = string
  description   = "Startup script for instance"
  default       = ""
}

variable "tags" {
  type          = list(string)
  description   = "Tags for server"
}

variable "disk_size" {
  type          = string
  description   = "Disk size for template"
}

variable "source_image" {
  type          = string
  description   = "Source image"
}

variable "auto_delete" {
  type          = bool
  description   = "GCP Auto-delete disk on instance deletion. Default: true"
  default       = true
}

variable "network_name" {
  type          = string
  description   = "GCP VPC network name"
}

variable "subnet_name" {
  type          = string
  description   = "Subnet Name"
}
