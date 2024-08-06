#----------------------------------------------------------------------------------------------------------------------
# Network
#----------------------------------------------------------------------------------------------------------------------

resource "azurerm_virtual_network" "vnet00" {
  name                = "vnet-hubnetwork-p-${var.location_short}"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name
  address_space       = var.hub_address_space
}

# Create Subnets
resource "azurerm_subnet" "management00" {
  name                 = "subnet-mgmt-p-${var.location_short}"
  virtual_network_name = azurerm_virtual_network.vnet00.name
  resource_group_name  = var.resource_group_networking.name
  address_prefixes     = var.mgmt_space_prefix
}

resource "azurerm_subnet" "ha200" {
  name                 = "subnet-ha2-p-${var.location_short}"
  virtual_network_name = azurerm_virtual_network.vnet00.name
  resource_group_name  = var.resource_group_networking.name
  address_prefixes     = var.ha2_space_prefix
}

resource "azurerm_subnet" "private00" {
  name                 = "subnet-private-p-${var.location_short}"
  virtual_network_name = azurerm_virtual_network.vnet00.name
  resource_group_name  = var.resource_group_networking.name
  address_prefixes     = var.private_space_prefix
}

resource "azurerm_subnet" "public00" {
  name                 = "subnet-public-p-${var.location_short}"
  virtual_network_name = azurerm_virtual_network.vnet00.name
  resource_group_name  = var.resource_group_networking.name
  address_prefixes     = var.public_space_prefix
}

resource "azurerm_subnet" "loadbalancer00" {
  name                 = "subnet-loadbalancer-p-${var.location_short}"
  virtual_network_name = azurerm_virtual_network.vnet00.name
  resource_group_name  = var.resource_group_networking.name
  address_prefixes     = var.lb_space_prefix
}

#----------------------------------------------------------------------------------------------------------------------
# Network - Azure Virtual WAN
#----------------------------------------------------------------------------------------------------------------------

#Get vWAN ID
data "azurerm_virtual_wan" "vwan" {
  name                                          = "vwan-rush"
  resource_group_name                           = "rush-west"
}

# Creation of vHUB in default location - For DR we need to add second HUB
resource "azurerm_virtual_hub" "hub" {
  name                = "vhub-hubnetwork-p-${var.location_short}"
  resource_group_name = var.resource_group_networking.name
  location            = var.resource_group_networking.location
  virtual_wan_id      = data.azurerm_virtual_wan.vwan.id
  address_prefix      = var.virtual_wan_address_space[0]
}

resource "azurerm_vpn_gateway" "hub_gateway" {
  name                = "gateway-hubnetwork-p-${var.location_short}"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name
  virtual_hub_id      = azurerm_virtual_hub.hub.id
  scale_unit          = 2
}


# This is the vWAN peer to Firewall vnet - Required for traffic fitlering from External Connections. That ONLy works when we are within same Tenant.
resource "azurerm_virtual_hub_connection" "connection_hub" {
  name                      = "peer-hubnetwork-p-${var.location_short}"
  virtual_hub_id            = azurerm_virtual_hub.hub.id
  remote_virtual_network_id = azurerm_virtual_network.vnet00.id
}

resource "azurerm_express_route_gateway" "ergateway" {
  name                = "ergw-hubnetwork-p-${var.location_short}"
  resource_group_name = var.resource_group_networking.name
  location            = var.resource_group_networking.location
  virtual_hub_id      = azurerm_virtual_hub.hub.id
  scale_units         = 1

}

#----------------------------------------------------------------------------------------------------------------------
# NAT Gateway
#----------------------------------------------------------------------------------------------------------------------

# NAT GW Public IP

resource "azurerm_public_ip" "ext_natgw_pip" {
  name                = "pip-natgw-p-${var.location_short}"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Build NAT Gateway

resource "azurerm_nat_gateway" "ext_natgw" {
  name                    = "ng-extnatgw-p-${var.location_short}"
  location                = var.resource_group_networking.location
  resource_group_name     = var.resource_group_networking.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

# Associate Public IP

resource "azurerm_nat_gateway_public_ip_association" "ext_natgwpip_associate" {
  nat_gateway_id       = azurerm_nat_gateway.ext_natgw.id
  public_ip_address_id = azurerm_public_ip.ext_natgw_pip.id
}

# Associate puplic subnets

resource "azurerm_subnet_nat_gateway_association" "ext_natgw_subnet" {
  subnet_id      = azurerm_subnet.public00.id
  nat_gateway_id = azurerm_nat_gateway.ext_natgw.id
}
