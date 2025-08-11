variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "vnet_name" {
  type        = string
}

variable "bastion_subnet_name" {
    description = "Bastion subnet name"
    type        = string
    default     = "subnet-bastion"
}

variable "bastion_subnet_prefix" {
    description = "Address prefix of bastion subnet"
    type        = list(string)
    default     = ["10.0.3.0/27"]
}

variable "bastion_pub_ip_name" {
    type        = string
    default     = "bastion-public_ip"
}

variable "bastion_pub_ip_sku" {
    type        = string
    default     = "Basic"
}

variable "bastion_nic_name" {
    type        = string
    default     = "bastion-nic"
}

variable "bastion_nsg_name" {
    type        = string
    default     = "bastion-nsg"
}

variable "nsg_priority" {
    description = "NSG priority map"
    type        = map(number)
    default     = {
        allow_ssh = 1000
    }
}

variable "jumpserver_name" {
    type        = string
    default     = "Bastion"
}

variable "jumpserver_size" {
    type        = string
    default     = "Standard_B1ls"
}