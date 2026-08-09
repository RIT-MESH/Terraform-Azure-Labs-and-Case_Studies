# 21 — Adding a data disk

Attach a managed data disk to the VM from lab 17 using
`azurerm_managed_disk` + `azurerm_virtual_machine_data_disk_attachment`. The OS disk holds
the OS; data disks hold your application data and can be detached and re-attached.
