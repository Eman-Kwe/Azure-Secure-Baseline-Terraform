# Standard SKU public IPs deny all inbound until an NSG allows it
resource "azurerm_public_ip" "vm" {
  name                = "pip-${local.name_prefix}-vm"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-${local.name_prefix}-vm"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id # app tier
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "lab" {
  name                = "vm-${local.name_prefix}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  size                = var.vm_size # must be available to the subscription in var.location (az vm list-skus)
  admin_username      = var.admin_username
  tags                = local.common_tags

  disable_password_authentication = true # SSH keys only — kills password attacks

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  network_interface_ids = [azurerm_network_interface.vm.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # cheapest; Premium in prod
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # VM gets its own Entra ID identity — Key Vault access with no creds on disk
  identity {
    type = "SystemAssigned"
  }
}

# Auto-shutdown 7 PM ET — removes ~73% of compute hours for a 9-to-5 lab
resource "azurerm_dev_test_global_vm_shutdown_schedule" "lab" {
  virtual_machine_id    = azurerm_linux_virtual_machine.lab.id
  location              = azurerm_resource_group.lab.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "Eastern Standard Time"

  notification_settings {
    enabled = false # prod: true, with a warning webhook
  }
}