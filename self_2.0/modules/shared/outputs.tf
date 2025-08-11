output "location" {
  value = azurerm_resource_group.main.location
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}