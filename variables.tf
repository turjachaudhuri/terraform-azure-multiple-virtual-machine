# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "app_identifier" {
  description = "Default name to use with your resource names."
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "entity" {
  description = "name of the entity"
  default     = "default"
}

variable "enviornment" {
  description = "define the enviornment - PROD / DEV"
}

variable "resource_group" {
  description = "name of the resource group"
}

variable "lorealregiontoregion" {
  description = "mapping between the aws regions and loreal region names"
  default     = {}
}

variable "lorealregiontoregionnc" {
  description = "mapping between the aws regions and loreal region names naming convention"
  default     = {}
}

variable "lorealregiontoidentifier" {
  description = "mapping between the regions and loreal region names naming convention"
  type = "map"
}
#tags
variable "tags" {
    type = "map"
}

variable "faultdomain" {
  description = "Number of fault domain for ASet : https://docs.microsoft.com/en-us/azure/virtual-machines/windows/manage-availability#number-of-fault-domains-per-region"
  default = "2"
}

variable "updatedomain" {
  description = "Number of fault domain for ASet : https://docs.microsoft.com/en-us/azure/virtual-machines/windows/manage-availability#number-of-fault-domains-per-region"
  default = "2"
}

variable "network_security_group_id" {
  description = "(Optional) The ID of the Network Security Group to associate with the network interface."
  type = "list"
}

variable "network_security_group_name" {
  description = "(Optional) The ID of the Network Security Group to associate with the network interface."
  type = "list"
}


variable "windows_os_only_vm_definition" {
  type="list"
}

variable "subnet_name_list" {
  type="list"
}
variable "subnet_id_list" {
  type="list"
}
variable "availability_set_id_list" {
  type="list"
}

variable "availability_set_name_list" {
  type="list"
}

variable "storage_endpoint" {
}

variable depends_on { default = [], type = "list"}

variable "domain_addition_list" {type = "list"}