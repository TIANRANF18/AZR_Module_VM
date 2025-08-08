variable "resource_group_name" {
  description = "The name of the resource group in which to create the VM"
  type        = string
}

variable "location" {
  description = "The Azure region where the VM will be created"
  type        = string
}

variable "vms" {
  description = "Map of VM configurations"
  type = map(object({
    vm_name          = string
    vm_size          = string
    admin_username   = string
    admin_password   = optional(string)
    ssh_public_key   = optional(string)
    os_disk_type     = string
    os_image_publisher = string
    os_image_offer   = string
    os_image_sku     = string
    os_image_version = string
    subnet_id        = string
    public_ip        = bool
    data_disks = optional(list(object({
      name         = string
      disk_size_gb = number
      lun          = number
      caching      = string
    })), [])
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "nsg_id" {
  description = "Network Security Group ID to associate with the NIC"
  type        = string
  default     = null
}