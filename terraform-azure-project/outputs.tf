output "public_ip" {
  value = azurerm_linux_virtual_machine.amdevops_vm.public_ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.amdevops_vm.id
}

output "resource_group_name" {
  value = azurerm_resource_group.amdevops_rg.name
}