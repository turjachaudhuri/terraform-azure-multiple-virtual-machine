######################################################################
# This module is used to create vnet. The same module will           #
# be used for hybrid and DC extension vnet :                         #
# For hybdrid vnet, the hybrid_env will be set to true               #
# For dc extension vnet, the hybrid_env variable will be se to false #
######################################################################

# ---------------------------------------------------------------------------------------------------------------------
# SECTION 1: CREATE NSG RULE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = "= 0.11.13"
}

resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${join("", var.depends_on)}"
  }
}

locals {
  subnet_id = "${var.subnet_id_list}"
  subnet_name = "${var.subnet_name_list}"
  
  availability_set_id  = "${var.availability_set_id_list}"
  availability_set_name = "${var.availability_set_name_list}"
  network_security_group_id = "${var.network_security_group_id}"
  network_security_group_name = "${var.network_security_group_name}"
}

locals {
  subnet_map = "${zipmap(local.subnet_name, local.subnet_id)}"
  availability_set_map = "${zipmap(local.availability_set_name, local.availability_set_id)}"
  network_security_group_map = "${zipmap(local.network_security_group_name, local.network_security_group_id)}"
}



resource "azurerm_network_interface" "vm-nic" {
  depends_on = ["null_resource.depends_on"]
  count                         = "${length(var.windows_os_only_vm_definition)}"
  name                          = "${format("%s-%s-%s-%s-%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"NIC",var.enviornment,lookup(var.windows_os_only_vm_definition[count.index],"vmidentifier"))}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group}"
  network_security_group_id     =  "${lookup(local.network_security_group_map, format("%s-%s-%s-%s-%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"NSG",var.enviornment,lookup(var.windows_os_only_vm_definition[count.index],"vm_nsg_identifier")))}"
  ip_configuration {
    name                          = "${format("%s-%s-%s-%s-%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"IPC",var.enviornment,lookup(var.windows_os_only_vm_definition[count.index],"vmidentifier"))}"
    private_ip_address_allocation = "${lookup(var.windows_os_only_vm_definition[count.index],"private_ip_address_allocation")}"
    private_ip_address_version    = "${lookup(var.windows_os_only_vm_definition[count.index],"private_ip_address_version")}"
    private_ip_address            = "${lookup(var.windows_os_only_vm_definition[count.index],"vmip")}"
    subnet_id                     = "${lookup(local.subnet_map, format("%s-%s-%s-%s-%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"SUB",var.enviornment,lookup(var.windows_os_only_vm_definition[count.index],"subnet_identifier")))}"
  }
  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "VM" {
  depends_on            = ["azurerm_network_interface.vm-nic"]
  count                 = "${length(var.windows_os_only_vm_definition)}"  
  name                  = "${lookup(var.windows_os_only_vm_definition[count.index],"vmname")}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group}"
  network_interface_ids = ["${azurerm_network_interface.vm-nic.*.id[count.index]}"]
  vm_size               = "${lookup(var.windows_os_only_vm_definition[count.index],"vm_specification")}"
  availability_set_id   = "${lookup(local.availability_set_map, "${format("%s-%s-%s-%s-%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"AVS",var.enviornment,lookup(var.windows_os_only_vm_definition[count.index],"availability_set_identifier"))}" )}"
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${lookup(var.windows_os_only_vm_definition[count.index],"vm_storage_image_reference_publisher")}"
    offer     = "${lookup(var.windows_os_only_vm_definition[count.index],"vm_storage_image_reference_offer")}"
    sku       = "${lookup(var.windows_os_only_vm_definition[count.index],"vm_storage_image_reference_sku")}"
    version   = "${lookup(var.windows_os_only_vm_definition[count.index],"vm_storage_image_reference_version")}"
  }
  storage_os_disk {
    name              = "${format("%s-%s-%s-%s-%s",lookup(var.lorealregiontoregionnc,var.location),var.entity,"OSD",var.enviornment,lookup(var.windows_os_only_vm_definition[count.index],"vmidentifier"))}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${lookup(var.windows_os_only_vm_definition[count.index],"storage_os_disk_managed_disk_type")}"
    disk_size_gb      = "${lookup(var.windows_os_only_vm_definition[count.index],"OS_disk_size_gb")}"
  }
  os_profile {
    computer_name  = "${lookup(var.windows_os_only_vm_definition[count.index],"vmname")}"
    admin_username = "${lower(format("%s%s%s%s%s",lookup(var.lorealregiontoidentifier,var.location),var.entity,"SRVA",var.enviornment,var.app_identifier))}"
    admin_password = "${lookup(var.windows_os_only_vm_definition[count.index],"vm_admin_password")}"
  }
  boot_diagnostics {
        enabled     = "${lookup(var.windows_os_only_vm_definition[count.index],"boot_diagnostics_enabled")}"
        storage_uri = "${var.storage_endpoint}"
    }

  os_profile_windows_config {
        provision_vm_agent = "${lookup(var.windows_os_only_vm_definition[count.index],"provision_vm_agent")}"
        enable_automatic_upgrades = "${lookup(var.windows_os_only_vm_definition[count.index],"enable_automatic_upgrades")}"
  }
  tags = "${var.tags}"
}