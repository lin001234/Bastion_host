module "shared" {
  source = "../modules/shared"

  location          = "East Asia"
  resource_grp_name = "Bastion_tryout"
}

locals {
  location            = module.shared.location
  resource_group_name = module.shared.resource_group_name
  vnet_name           = module.shared.vnet_name
}

module "jump_server" {
  source = "../modules/jump_server"

  nsg_priority = {
    allow_ssh = 200
  }
  location            = local.location
  resource_group_name = local.resource_group_name
  vnet_name           = local.vnet_name
}

module "app_vm" {
  source = "../modules/app_vm"

  vm_name             = "VM-Project1"
  vm_nic_name         = "VM-nic"
  vm_nsg_name         = "VM-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name
  vnet_name           = local.vnet_name
  bastion_pub_ip      = module.jump_server.bastion_pub_ip
}