# JD #7: Networking concepts — VNet, Subnet, NSG
# JD #9: OS security for publicly accessible servers

resource "azurerm_virtual_network" "hrw" {
  name                = "hrw-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "default" {
  name                 = "hrw-subnet-default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hrw.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSG — deny all inbound by default
# Only HTTPS (443) is explicitly allowed
# This is least-privilege networking — mention this in the interview
resource "azurerm_network_security_group" "hrw" {
  name                = "hrw-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "hrw" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.hrw.id
}

output "vnet_id" {
  value = azurerm_virtual_network.hrw.id
}

output "subnet_id" {
  value = azurerm_subnet.default.id
}

output "nsg_id" {
  value = azurerm_network_security_group.hrw.id
}