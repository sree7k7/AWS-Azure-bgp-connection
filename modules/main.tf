## This template creates on Vnet and two subnets (public and private) and vm
# Create Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name_prefix
}

# Create virtual network
resource "azurerm_virtual_network" "vnet_work" {
  name                = var.vnet_config["vnetname"]
  address_space       = ["${var.vnet_cidr}"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create public subnet
resource "azurerm_subnet" "vnet_public_subnet" {
  name                 = var.vnet_config["public_subnet"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_work.name
  address_prefixes     = ["${var.public_subnet_address}"]
}

# Create private subnet
resource "azurerm_subnet" "vnet_private_subnet" {
  name                 = var.vnet_config["private_subnet"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_work.name
  address_prefixes     = ["${var.private_subnet_address}"]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "SecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "InternetAccess"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create public IP for vm
resource "azurerm_public_ip" "public_ip" {
  name                = "PublicIp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
  allocation_method   = "Static"
}
# Create network interface
resource "azurerm_network_interface" "vm_public_nic" {
  name                = "NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic_config"
    subnet_id                     = azurerm_subnet.vnet_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect the security group to the network interface (NIC)
resource "azurerm_network_interface_security_group_association" "connect_nsg_to_nic" {
  network_interface_id      = azurerm_network_interface.vm_public_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${var.resource_group_location}-Vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vm_public_nic.id]
  size                  = "Standard_DS1_v2"
  admin_username                  = "demousr"
  admin_password                  = "Password@123"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
    {
        "commandToExecute":"powershell -ExecutionPolicy Unrestricted Add-WindowsFeature Web-Server; powershell -ExecutionPolicy Unrestricted Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.html\" -Value $($env:computername)"
    }
SETTINGS
}

##create azure GatewaySubnet
resource "azurerm_subnet" "vnet_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_work.name
  address_prefixes     = ["${var.gateway_subnet_address}"]
}

# vpngw pip instance0
resource "azurerm_public_ip" "VPNGW_pip1" {
  name                = "VPNGW_pip1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
  allocation_method   = "Static"
  zones = [1,2,3]
}
# vpngw pip instance1
resource "azurerm_public_ip" "VPNGW_pip2" {
  name                = "VPNGW_pip2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
  allocation_method   = "Static"
  zones = [1,2,3]
}

##create azure virtual network gateway 
resource "azurerm_virtual_network_gateway" "VirtualNetworkGateway" {
  name                = "VirtualNetworkGateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1AZ"
  enable_bgp          = true
  active_active       = true

  bgp_settings {
    asn                           = 65000
    # peering_address =             = "10.5.0.13"
    peering_addresses {
      apipa_addresses       = var.custom_apipa_bgp_ip_addresses
      ip_configuration_name = "vnetGatewayConfig1"
    }
    peering_addresses {
      apipa_addresses       = var.connection2_custom_apipa_bgp_ip_addresses
      # apipa_addresses       = ["169.254.21.6","169.254.22.6"]
      ip_configuration_name = "vnetGatewayConfig2"
    }
  }

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.VPNGW_pip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_gateway_subnet.id
  }
  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = azurerm_public_ip.VPNGW_pip2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vnet_gateway_subnet.id
  }
}

# Local network Gateway pointing to AWS S2S connection 1 tunnel-1
resource "azurerm_local_network_gateway" "LGW_AWSTunnel1ToVPNGWInstance0" {
  name                = "LGW_AWSTunnel1ToVPNGWInstance0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = var.vpn_gateway_pip_tunnel1

  bgp_settings {
      asn                 = var.asn
      bgp_peering_address = var.aws_bgp_ip_address_tunnel1
      peer_weight         = 0
    }
  depends_on = [
    azurerm_virtual_network_gateway.VirtualNetworkGateway
  ]
}

# Site VPN connection
resource "azurerm_virtual_network_gateway_connection" "connection1_AWSTunnel1ToVPNGWInstance0" {
  name                = "AWSTunnel1ToVPNGWInstance0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VirtualNetworkGateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.LGW_AWSTunnel1ToVPNGWInstance0.id
  shared_key = var.shared_key_tunnel1
  enable_bgp = true
  custom_bgp_addresses {
    primary = var.AWSTunnel1ToVPNGWInstance0_primary_custom_bpg_address
    secondary = var.secondary_custom_bgp_ip_address
  }
}

## Local network Gateway pointing to AWS S2S connection 1 tunnel-2
resource "azurerm_local_network_gateway" "LGW_AWSTunnel2ToVPNGWInstance0" {
  name                = "LGW_AWSTunnel2ToVPNGWInstance0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = var.vpn_gateway_pip_tunne2

  bgp_settings {
      asn                 = var.asn
      bgp_peering_address = var.aws_bgp_ip_address_tunnel2
      peer_weight         = 0
    }
  depends_on = [
    azurerm_virtual_network_gateway.VirtualNetworkGateway
  ]
}

# Site VPN connection
resource "azurerm_virtual_network_gateway_connection" "connection1_AWSTunnel2ToVPNGWInstance0" {
  name                = "AWSTunnel2ToVPNGWInstance0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VirtualNetworkGateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.LGW_AWSTunnel2ToVPNGWInstance0.id
  shared_key = var.shared_key_tunnel2
  enable_bgp = true
  custom_bgp_addresses {
    primary = var.AWSTunnel2ToVPNGWInstance0_primary_custom_bpg_address
    secondary = var.secondary_custom_bgp_ip_address
  }
}

##---------- Local network gateway pointing to aws s2s connection 2-----

## Local network Gateway pointing to AWS S2S connection 2 tunnel-1
resource "azurerm_local_network_gateway" "LGW_S2S_2_AWSTunnel1ToVPNGWInstance1" {
  name                = "LGW_S2S_2_AWSTunnel1ToVPNGWInstance1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = var.connection2_vpn_gateway_pip_tunnel1

  bgp_settings {
      asn                 = var.asn
      bgp_peering_address = var.aws_bgp_ip_address_connection2_tunnel1
      peer_weight         = 0
    }
  depends_on = [
    azurerm_virtual_network_gateway.VirtualNetworkGateway
  ]
}

# Site VPN connection
resource "azurerm_virtual_network_gateway_connection" "S2SConnection2_AWSTunnel1ToVPNGWInstance1" {
  name                = "S2SConnection2_AWSTunnel1ToVPNGWInstance1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VirtualNetworkGateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.LGW_S2S_2_AWSTunnel1ToVPNGWInstance1.id
  shared_key = var.shared_key_connection2_tunnel1
  enable_bgp = true
  custom_bgp_addresses {
    primary = var.connection2_AWSTunnel1ToVPNGWInstance1_primary_custom_bpg_address
    secondary = var.connection2_secondary_custom_bgp_ip_address
  }
}

## Local network Gateway pointing to AWS S2S connection 2 tunnel-2
resource "azurerm_local_network_gateway" "LGW_S2S_2_AWSTunnel2ToVPNGWInstance1" {
  name                = "LGW_S2S_2_AWSTunnel2ToVPNGWInstance1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = var.connection2_vpn_gateway_pip_tunnel2

  bgp_settings {
      asn                 = var.asn
      bgp_peering_address = var.aws_bgp_ip_address_connection2_tunnel2
      peer_weight         = 0
    }
  depends_on = [
    azurerm_virtual_network_gateway.VirtualNetworkGateway
  ]
}

# # Site VPN connection
resource "azurerm_virtual_network_gateway_connection" "S2SConnection2_AWSTunnel2ToVPNGWInstance1" {
  name                = "S2SConnection2_AWSTunnel2ToVPNGWInstance1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VirtualNetworkGateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.LGW_S2S_2_AWSTunnel2ToVPNGWInstance1.id
  shared_key = var.shared_key_connection2_tunnel2
  enable_bgp = true
  custom_bgp_addresses {
    primary = var.connection2_AWSTunnel2ToVPNGWInstance1_primary_custom_bpg_address
    secondary = var.connection2_secondary_custom_bgp_ip_address
  }
}


# Azure Bastion host
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_work.name
  address_prefixes     = ["${var.bastion_subnet_address}"]
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "bastion_pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "BastionHost" {
  name                = "BastionHost"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "bastion_pip_config"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
