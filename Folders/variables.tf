variable "parent_id" {
  type          = string
  description   = "Id of the parent resource"
}

variable "parent_type" {
  type          = string
  description   = "Type of the parent resource. `organizations`(default) or `folders`"
  default       = "organizations"
}

variable "folder_names" {
  type          = list(string)
  description   = "Folder names."
  default       = []
}
