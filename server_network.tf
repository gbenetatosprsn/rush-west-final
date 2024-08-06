#----------------------------------------------------------------------------------------------------------------------
# VM-Series - MGMT
#----------------------------------------------------------------------------------------------------------------------

# Public IP Address:
#Internal Firewalls
resource "azurerm_public_ip" "int_p_management00" {
  name                = "pip-intmanagement-p-${var.location_short}"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name
  allocation_method   = "Static"
  sku                 = "Standard"
}



#External Firewalls
resource "azurerm_public_ip" "ext_p_management00" {
  name                = "pip-extmanagement-p-${var.location_short}"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface:
##Internal Firewalls
resource "azurerm_network_interface" "int_p_management00" {
  name                 = "nic-intmanagement-p-${var.location_short}"
  location             = var.resource_group_networking.location
  resource_group_name  = var.resource_group_networking.name
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "ipconfig00"
    subnet_id                     = azurerm_subnet.management00.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.hub_address_space[0], 4)
    public_ip_address_id          = azurerm_public_ip.int_p_management00.id
  }
}

##External Firewalls

resource "azurerm_network_interface" "ext_p_management00" {
  name                 = "nic-extmanagement-p-${var.location_short}"
  location             = var.resource_group_networking.location
  resource_group_name  = var.resource_group_networking.name
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "ipconfig00"
    subnet_id                     = azurerm_subnet.management00.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.hub_address_space[0], 8)
    public_ip_address_id          = azurerm_public_ip.ext_p_management00.id
  }
}

# Network Security Group:
## Internal FW
resource "azurerm_network_security_group" "int_management00" {
  name                = "nsg-intmanagement-${var.location_short}"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name

  security_rule {
    name                       = "Deny_ALL"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "default-access-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-To-DNS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-To-HA"
    priority                   = 150
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefixes = ["10.41.1.68","10.41.1.69","10.41.1.70","10.41.1.71"]
  }

  security_rule {
    name                       = "Allow-To-Mail"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "25"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-To-LDAP"
    priority                   = 250
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-To-Panorama"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/8"
  }

  security_rule {
    name                       = "Block-Private-Ranges"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefixes = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12"]
  }

  
}


## External FW
resource "azurerm_network_security_group" "ext_management00" {
  name                = "nsg-extmanagement-${var.location_short}"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name

  security_rule {
    name                       = "Deny_ALL"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "default-access-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-To-DNS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-To-HA"
    priority                   = 150
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefixes = ["10.41.1.72","10.41.1.73","10.41.1.74","10.41.1.75"]
  }

  security_rule {
    name                       = "Allow-To-Mail"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "25"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-To-LDAP"
    priority                   = 250
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-To-Panorama"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/8"
  }

  security_rule {
    name                       = "Block-Private-Ranges"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefixes = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12"]
  }

  
}

#Attach NSG to Interfaces
##Internal FW

resource "azurerm_network_interface_security_group_association" "int_p_management00" {
  network_interface_id      = azurerm_network_interface.int_p_management00.id
  network_security_group_id = azurerm_network_security_group.int_management00.id
}


##External FW

resource "azurerm_network_interface_security_group_association" "ext_p_mgmt00" {
  network_interface_id      = azurerm_network_interface.ext_p_management00.id
  network_security_group_id = azurerm_network_security_group.ext_management00.id
}


#----------------------------------------------------------------------------------------------------------------------
# VM-Series - Ethernet0/1 Interface (Untrust)
#----------------------------------------------------------------------------------------------------------------------

/*
# Public IP Address - NATGW - NO Need for PIP
resource "azurerm_public_ip" "ethernet00_0_1" {
  name                = "nic-ethernet00_0_1-pip"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "ethernet01_0_1" {
  name                = "nic-ethernet01_0_1-pip"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
*/

# Network Interface
# Internal Firewalls
resource "azurerm_network_interface" "int_p_public00" {
  name                          = "nic-intpublic-p-${var.location_short}"
  location                      = var.resource_group_networking.location
  resource_group_name           = var.resource_group_networking.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.public00.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.hub_address_space[0], 132)
  }
}



# External Firewalls
resource "azurerm_network_interface" "ext_p_public00" {
  name                          = "nic-extpublic-p-${var.location_short}"
  location                      = var.resource_group_networking.location
  resource_group_name           = var.resource_group_networking.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.public00.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.hub_address_space[0], 136)
  }
}



#Data NSG

resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-${var.location_short}"
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name

  security_rule {
    name                       = "data-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "data-outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#NSG Attachment
##Internal FW

resource "azurerm_network_interface_security_group_association" "int_p_public_00" {
  network_interface_id      = azurerm_network_interface.int_p_public00.id
  network_security_group_id = azurerm_network_security_group.data.id
}


##External Firewall

resource "azurerm_network_interface_security_group_association" "ext_p_public_00" {
  network_interface_id      = azurerm_network_interface.ext_p_public00.id
  network_security_group_id = azurerm_network_security_group.data.id
}


#----------------------------------------------------------------------------------------------------------------------
# VM-Series - Ethernet0/2 Interface (Trust)
#----------------------------------------------------------------------------------------------------------------------

# Network Interface
## Internal Firewalls
resource "azurerm_network_interface" "int_p_trust00" {
  name                          = "nic-inttrust-p-${var.location_short}"
  location                      = var.resource_group_networking.location
  resource_group_name           = var.resource_group_networking.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true


  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.private00.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.hub_address_space[0], 36)
  }
}



## External Firewalls
resource "azurerm_network_interface" "ext_p_trust00" {
  name                          = "nic-exttrust-p-${var.location_short}"
  location                      = var.resource_group_networking.location
  resource_group_name           = var.resource_group_networking.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true


  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.private00.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.hub_address_space[0], 40)
  }
}


#NSG Attachment
##Internal FW

resource "azurerm_network_interface_security_group_association" "int_p_trust00" {
  network_interface_id      = azurerm_network_interface.int_p_trust00.id
  network_security_group_id = azurerm_network_security_group.data.id
}


##External Firewall

resource "azurerm_network_interface_security_group_association" "ext_p_trust_00" {
  network_interface_id      = azurerm_network_interface.ext_p_trust00.id
  network_security_group_id = azurerm_network_security_group.data.id
}

#----------------------------------------------------------------------------------------------------------------------
# VM-Series - Ethernet0/3 Interface (HA2)
#----------------------------------------------------------------------------------------------------------------------

# Network Interface
## Internal Firewalls
resource "azurerm_network_interface" "int_p_ha00" {
  name                          = "nic-intha2-p-${var.location_short}"
  location                      = var.resource_group_networking.location
  resource_group_name           = var.resource_group_networking.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.ha200.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.hub_address_space[0], 68)
  }
}


##External Firewall

resource "azurerm_network_interface" "ext_p_ha00" {
  name                          = "nic-extha2-p-${var.location_short}"
  location                      = var.resource_group_networking.location
  resource_group_name           = var.resource_group_networking.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.ha200.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.hub_address_space[0], 72)
  }
}


#----------------------------------------------------------------------------------------------------------------------
# VM-Series - Virtual Machine
#----------------------------------------------------------------------------------------------------------------------

#Internal PRD - FW1

resource "azurerm_marketplace_agreement" "palo" {
  publisher = "paloaltonetworks"
  offer     = "vmseries-flex"
  plan      = "byol"
}

resource "azurerm_linux_virtual_machine" "int_p_vmseries00" {
  # Resource Group & Location:
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name

  name = "vm-intpa-p-${var.location_short}"

  # Availabilty Zone:
  zone = "1"

  # Instance
  size = "Standard_DS3_v2"

  # Username and Password Authentication:
  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password

  # Network Interfaces:
  network_interface_ids = [
    azurerm_network_interface.int_p_management00.id,
    azurerm_network_interface.int_p_public00.id,
    azurerm_network_interface.int_p_trust00.id,
    azurerm_network_interface.int_p_ha00.id,
  ]

  plan {
    name      = "byol"
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = "byol"
    version   = "latest"
    #command = "az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan byol"
  }

  os_disk {
    name                 = "${var.coid}osdiskintpap${var.location_short}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  tags = {
    description = "Palo Alto Firewall Internal Production"
    environment = "p"
  }
}

#External PRD - FW1


resource "azurerm_linux_virtual_machine" "ext_p_vmseries00" {
  # Resource Group & Location:
  location            = var.resource_group_networking.location
  resource_group_name = var.resource_group_networking.name

  name = "vm-extpa-p-${var.location_short}"

  # Availabilty Zone:
  zone = "1"

  # Instance
  size = "Standard_DS3_v2"

  # Username and Password Authentication:
  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password

  # Network Interfaces:
  network_interface_ids = [
    azurerm_network_interface.ext_p_management00.id,
    azurerm_network_interface.ext_p_public00.id,
    azurerm_network_interface.ext_p_trust00.id,
    azurerm_network_interface.ext_p_ha00.id,
  ]

  plan {
    name      = "byol"
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = "byol"
    version   = "latest"
    #command = "az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan byol"
  }

  os_disk {
    name                 = "${var.coid}osdiskextpap${var.location_short}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  tags = {
    description = "Palo Alto Firewall External Production"
    environment = "p"
  }
}
