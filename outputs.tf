
output "vm_name" {
    value = "${azurerm_virtual_machine.VM.*.name}"
}

output "vm_id" {
    value = "${azurerm_virtual_machine.VM.*.id}"
}
