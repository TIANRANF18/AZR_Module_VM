resource "azurerm_public_ip" "vm" {
  for_each            = { for k, v in var.vms : k => v if v.public_ip }
  
  name                = "${each.value.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  tags                = each.value.tags
}

resource "azurerm_network_interface" "vm" {
  for_each            = var.vms
  
  name                = "${each.value.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.public_ip ? azurerm_public_ip.vm[each.key].id : null
  }

  tags = each.value.tags
}

resource "azurerm_network_interface_security_group_association" "vm" {
  for_each                  = var.nsg_id != null ? var.vms : {}

  network_interface_id      = azurerm_network_interface.vm[each.key].id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = var.vms
  
  name                  = each.value.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = each.value.vm_size
  admin_username        = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = each.value.ssh_public_key != null ? each.value.ssh_public_key : file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "${each.value.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
  }

  source_image_reference {
    publisher = each.value.os_image_publisher
    offer     = each.value.os_image_offer
    sku       = each.value.os_image_sku
    version   = each.value.os_image_version
  }

  # dynamic "admin_password" {
  #   for_each = each.value.admin_password != null ? [1] : []
  #   content {
  #     admin_password = each.value.admin_password
  #   }
  # }

  tags = each.value.tags
}

resource "azurerm_managed_disk" "data_disk" {
  for_each             = { for k, v in var.vms : k => v if length(v.data_disks) > 0 }
  
  for_each_disk        = each.value.data_disks
  name                 = each.value_disk.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value_disk.disk_size_gb
  tags                 = each.value.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  for_each           = { for k, v in var.vms : k => v if length(v.data_disks) > 0 }
  
  for_each_disk      = each.value.data_disks
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key][each.value_disk.name].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.key].id
  lun                = each.value_disk.lun
  caching            = each.value_disk.caching
}