output "vm_ids" {
  description = "Map of VM names to their IDs"
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "nic_ids" {
  description = "Map of VM names to their network interface IDs"
  value       = { for k, v in azurerm_network_interface.vm : k => v.id }
}

output "public_ip_addresses" {
  description = "Map of VM names to their public IP addresses (if applicable)"
  value       = { for k, v in azurerm_public_ip.vm : k => v.ip_address }
}

output "private_ip_addresses" {
  description = "Map of VM names to their private IP addresses"
  value       = { for k, v in azurerm_network_interface.vm : k => v.private_ip_address }
}