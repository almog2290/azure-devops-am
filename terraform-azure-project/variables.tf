variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "almog-devops"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "instance_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
}

variable "ssh_key_path" {
  description = "Path to the SSH public key for access"
  type        = string
  default     = "~/.ssh/id_rsa_azure.pub"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "3f79a68d-cf0d-4291-a31f-185897f7fda1"
}