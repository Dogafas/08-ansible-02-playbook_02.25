variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "service_account_key_file" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "each_vm" {
  type = list(object({
    name        = string
    platform_id = string
    cores       = number
    memory      = number
    disk_size   = number
  }))
}
