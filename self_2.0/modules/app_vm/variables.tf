variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "vnet_name" {
  type        = string
}

variable "bastion_pub_ip" {
  type        = string
}

variable "vm_subnet_name" {
  description = "VM subnet name"
  type        = string
  default     = "subnet-vm"
}

variable "vm_subnet_prefix" {
  description = "Address prefix of vm subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "vm_nic_name" {
  description = "Network interface name"
  type        = string
  default     = "vm-nic"
}

variable "vm_nsg_name" {
  description = "Network security group name"
  type        = string
  default     = "vm-nsg"
}

variable "nsg_priority" {
  description = "NSG priority map"
  type        = map(number)
  default     = {
    allow_ssh = 1000
  }
}

variable "vm_name" {
    type = string
    default = "vm-project1"
}

variable "vm1_size" {
    type = string
    default = "Standard_B1ls"
}