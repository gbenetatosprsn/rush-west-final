
#----------------------------------------------------------------------------------------------------------------------
# Network - HUB
#----------------------------------------------------------------------------------------------------------------------

module "palo_active_passive" {
  source = "./modules/palo_active_passive"

  coid           = local.coid
  environment    = local.environment
  location       = local.location
  location_short = local.location_short
  function       = local.function

  hub_address_space         = local.hub_address_space
  virtual_wan_address_space = local.virtual_wan_address_space
  mgmt_space_prefix         = [cidrsubnet(local.hub_address_space[0], 3, 0)]
  public_space_prefix       = [cidrsubnet(local.hub_address_space[0], 3, 4)]
  private_space_prefix      = [cidrsubnet(local.hub_address_space[0], 3, 1)]
  ha2_space_prefix          = [cidrsubnet(local.hub_address_space[0], 3, 2)]
  lb_space_prefix           = [cidrsubnet(local.hub_address_space[0], 3, 3)]
  resource_group_networking = azurerm_resource_group.resource_group_networking00

  admin_username = var.admin_username_networking
  admin_password = var.admin_password_init
}

#----------------------------------------------------------------------------------------------------------------------
# Resource Group
#----------------------------------------------------------------------------------------------------------------------


resource "azurerm_resource_group" "resource_group_networking00" {
  name     = "rg-network-p-${local.location_short}"
  location = local.location

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. as customers sometimes want to co-mingle their own
      tags,
    ]
  }
}


resource "azurerm_resource_group" "resource_group_storage00" {
  name     = "rg-storage-p-${local.location_short}"
  location = local.location

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. as customers sometimes want to co-mingle their own
      tags,
    ]
  }
}

#----------------------------------------------------------------------------------------------------------------------
# Storage Accounts
#----------------------------------------------------------------------------------------------------------------------

resource "random_id" "storage_account00" {
  byte_length = 8
}

resource "azurerm_storage_account" "storagediag00" {
  name                = "${local.coid}${lower(random_id.storage_account00.hex)}"
  resource_group_name = azurerm_resource_group.resource_group_storage00.name

  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
  }

  tags = {
    "service" = "diagnostics"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. as customers sometimes want to co-mingle their own
      tags,
    ]
  }

}

resource "random_id" "storage_account01" {
  byte_length = 8
}

resource "azurerm_storage_account" "storagediag01" {
  name                = "${local.coid}${lower(random_id.storage_account01.hex)}"
  resource_group_name = azurerm_resource_group.resource_group_storage00.name

  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
  }

}

#----------------------------------------------------------------------------------------------------------------------
# Diagnostics
#----------------------------------------------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "logs" {
  name                           = "log-export"
  target_resource_id             = "/subscriptions/${var.subscription_id}"
  storage_account_id             = azurerm_storage_account.storagediag01.id
  log_analytics_destination_type = "AzureDiagnostics"

  enabled_log {
    category = "Administrative"
    retention_policy {
      enabled = false
    }
  }

  enabled_log {
    category = "Security"
    retention_policy {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. as customers sometimes want to co-mingle their own
      log_analytics_destination_type,
    ]
  }
}
