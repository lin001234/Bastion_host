resource "azurerm_resource_group" "main" {
    name     = var.resource_grp_name
    location = var.location
}


resource "azurerm_virtual_network" "vnet" {
    name    = var.vnet_name
    address_space   = var.vnet_address_space
    location    =   azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
}
