resource "azurerm_subnet" "subnet_bastion" {
    name    = var.bastion_subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes    = var.bastion_subnet_prefix
}

resource "azurerm_public_ip" "bastion_ip" {
    name                = var.bastion_pub_ip_name
    resource_group_name = var.resource_group_name
    location            = var.location
    allocation_method   = "Static"
    sku                 = var.bastion_pub_ip_sku

    tags = {
        environment = "Production"
    }
}

resource "azurerm_network_interface" "nic_bastion" {
  name                = var.bastion_nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-internal"
    subnet_id                     = azurerm_subnet.subnet_bastion.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_ip.id
  }
}

# Network security(allow ssh into bastion)
resource "azurerm_network_security_group" "Bastion_nsg" {
  name                = var.bastion_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow_ssh"
    priority                   = var.nsg_priority["allow_ssh"]
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface_security_group_association" "NSG_association_bastion" {
  network_interface_id      = azurerm_network_interface.nic_bastion.id
  network_security_group_id = azurerm_network_security_group.Bastion_nsg.id
}

resource "azurerm_linux_virtual_machine" "Bastion" {
  name                = var.jumpserver_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.jumpserver_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic_bastion.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/khant/.ssh/vm.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
