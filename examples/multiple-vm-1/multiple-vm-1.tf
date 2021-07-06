###############################
## Terraform VNET deployment ##
## ------------------------- ##
##     PROJECT MANIFEST      ##
###############################

### Configurtion file is located in ./configuration-files directory
### Configuartion file naming convention azure-<lorealregion>-<entity>.tfvars

### The comments for variable explanation are located in configuration file

### The credentials and subscriptions informations is defined with Azure CLI
### More informations : https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html

# ---------------------------------------------------------------------------------------------------------------------
# SECTION 2: VNET DEPLOYMENT
# ---------------------------------------------------------------------------------------------------------------------


resource "azurerm_availability_set" "vm-aset" {
  count                         = "${length(var.availability_set_definition)}"
  name                          = "${format("%s-%s-%s-%s-%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"AVS",var.enviornment,lookup(var.availability_set_definition[count.index],"avs_identifier"))}"
  location                      = "${var.location}"
  platform_fault_domain_count   = "${lookup(var.availability_set_definition[count.index],"platform_fault_domain_count")}"
  platform_update_domain_count  = "${lookup(var.availability_set_definition[count.index],"platform_update_domain_count")}"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  managed                       = "${lookup(var.availability_set_definition[count.index],"managed")}"
  tags                          = "${var.tags}"
}

resource "azurerm_storage_account" "storage-account" {
    count                     = "${length(var.storage_account_list)}"
    name                      = "${lower(format("%s%s%s%s%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"sto",var.enviornment,lookup(var.storage_account_list[count.index],"storage_account_identifier")))}"
    resource_group_name       = "${azurerm_resource_group.rg.name}"
    location                  = "${var.location}"
    account_kind              = "${lookup(var.storage_account_list[count.index],"storage_account_kind")}"
    account_replication_type  = "${lookup(var.storage_account_list[count.index],"storage_account_replication_type")}"
    account_tier              = "${lookup(var.storage_account_list[count.index],"storage_account_tier")}"
    access_tier               = "${lookup(var.storage_account_list[count.index],"storage_account_access_tier")}"
    enable_blob_encryption    = "${lookup(var.storage_account_list[count.index],"storage_account_enable_blob_encryption")}"
    enable_file_encryption    = "${lookup(var.storage_account_list[count.index],"storage_account_enable_file_encryption")}"
    enable_https_traffic_only = "${lookup(var.storage_account_list[count.index],"storage_account_enable_https_traffic")}" 
    tags                      = "${var.tags}"
}

locals {
  storage_account_map = "${zipmap(azurerm_storage_account.storage-account.*.name, azurerm_storage_account.storage-account.*.primary_blob_endpoint)}"
  public_ip_map = "${zipmap(azurerm_public_ip.public-ip.*.name,azurerm_public_ip.public-ip.*.id)}"
}
# ---------------------------------------------------------------------------------------------------------------------
# SECTION 3: CREATE VM
# ---------------------------------------------------------------------------------------------------------------------
module "windowsVM" {
     
    #Module source
     source = "../../modules/windows-only-vm-module"
    #Module variable
     app_identifier =  "${var.app_identifier}"

     lorealregiontoregionnc = "${var.lorealregiontoregionnc}"
     lorealregiontoregion   = "${var.lorealregiontoregion}"
     lorealregiontoidentifier = "${var.lorealregiontoidentifier}"

     entity         = "${var.entity}"
     resource_group = "${azurerm_resource_group.rg.name}"
     location       = "${var.location}"
     enviornment    = "${var.enviornment}"

     tags = "${var.tags}"

     windows_os_only_vm_definition = "${var.windows_os_only_vm_definition}"
    
     subnet_id_list = ["${concat(module.vnet.private_subnet_id, module.vnet.public_subnet_id)}"]
     subnet_name_list = ["${concat(module.vnet.private_subnet_name , module.vnet.public_subnet_name)}"]

     availability_set_id_list = "${azurerm_availability_set.vm-aset.*.id}"
     availability_set_name_list = "${azurerm_availability_set.vm-aset.*.name}"

     network_security_group_id = "${module.vnet.nsg_private_subnet_vm_standard}"
     network_security_group_name = "${module.vnet.nsg_private_subnet_vm_standard_name}"          

     storage_endpoint = "${lookup(local.storage_account_map,lower(format("%s%s%s%s%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"sto",var.enviornment,"hipbootdg")))}"

     depends_on = ["azurerm_storage_account.storage-account"]
}

