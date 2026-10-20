variable "cloud_id" { type = string }
variable "folder_id" { type = string }
variable "ssh_public_key" { type = string }
variable "vm_image_id" {
  type = string
  default = "fd83edrks3hbkigssvaa" # Твой ID образа Ubuntu
}