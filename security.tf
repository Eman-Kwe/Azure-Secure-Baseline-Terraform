# Global uniqueness for storage account and Key Vault names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Who am I? Used below to grant myself Key Vault access
data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "lab" {
  name                = "stazlab${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  tags                = local.common_tags

  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_key_vault" "lab" {
  name                = "kv-azlab-${random_string.suffix.result}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = local.common_tags

  rbac_authorization_enabled = true # modern permission model
}

# ME: full secret management
resource "azurerm_role_assignment" "me_kv_admin" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# THE VM: read-only, via its managed identity — the whole point of this lesson
resource "azurerm_role_assignment" "vm_kv_reader" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.vm_principal_id
}

# A demo secret to prove the VM can read it
resource "azurerm_key_vault_secret" "demo" {
  name         = "demo-db-connection"
  value        = "Server=example;Database=lab;Trusted_Connection=True;"
  key_vault_id = azurerm_key_vault.lab.id

  depends_on = [azurerm_role_assignment.me_kv_admin] # must have write access before writing
}