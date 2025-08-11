variable "resource_grp_name" {
    type        = string
    default     = "bastion-tryout"
}

variable "location" {
    type        = string
    default    = "West Europe"
}

variable "vnet_name" {
    type        = string
    default     = "Bastion-proj-vnet"
}

variable "vnet_address_space" {
    description = "Address space of vnet"
    type        = list(string)
    default     = ["10.0.0.0/16"]
}