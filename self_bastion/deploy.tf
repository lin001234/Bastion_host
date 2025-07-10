# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "bastion-tryout"
  location = "West Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-dev-myproject"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# VM subnet
resource "azurerm_subnet" "subnet_vm" {
  name                 = "subnet-vm"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Bastion subnet
resource "azurerm_subnet" "subnet_bastion" {
  name                 = "subnet-bastion"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/27"]
}

# Public ip for bastion host
resource "azurerm_public_ip" "bastion_ip" {
  name                = "bastion-publicIP"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Basic"

  tags = {
    environment = "Production"
  }
}

# Network Interface for bastion
resource "azurerm_network_interface" "nic_bastion" {
  name                = "nic-bastion"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig-internal"
    subnet_id                     = azurerm_subnet.subnet_bastion.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_ip.id
  }
}

# Network Interface for vm
resource "azurerm_network_interface" "nic_vm1" {
  name                = "nic-vm1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig-internal"
    subnet_id                     = azurerm_subnet.subnet_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network security(allow ssh from bastion)
resource "azurerm_network_security_group" "VM_nsg" {
  name                = "VM_nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "test123"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = azurerm_public_ip.bastion_ip.ip_address
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

# Network security(allow ssh into bastion)
resource "azurerm_network_security_group" "Bastion_nsg" {
  name                = "Bastion-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "test123"
    priority                   = 1000
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

# Association of NSG to VM
resource "azurerm_network_interface_security_group_association" "NSG_association_vm" {
  network_interface_id      = azurerm_network_interface.nic_vm1.id
  network_security_group_id = azurerm_network_security_group.VM_nsg.id
}

# Association of NSG to Bastion
resource "azurerm_network_interface_security_group_association" "NSG_association_bastion" {
  network_interface_id      = azurerm_network_interface.nic_bastion.id
  network_security_group_id = azurerm_network_security_group.Bastion_nsg.id
}

# Linux VM
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1-dev-myproject"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1ls"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic_vm1.id,
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

# Bastion VM
resource "azurerm_linux_virtual_machine" "Bastion" {
  name                = "Bastion"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1ls"
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
