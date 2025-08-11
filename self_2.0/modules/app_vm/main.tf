resource "azurerm_subnet" "subnet_vm" {
    name    = var.vm_subnet_name
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes    = var.vm_subnet_prefix
}

resource "azurerm_network_interface" "nic_vm1" {
  name                = var.vm_nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-internal"
    subnet_id                     = azurerm_subnet.subnet_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "VM_nsg" {
  name                = var.vm_nsg_name
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
    source_address_prefix      = var.bastion_pub_ip
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

# Linux VM
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm1_size
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