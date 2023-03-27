variable "resource_group_location" {
  default     = "northeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "aws-azure-bgp"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

# Vnet details
variable "vnet_config" {
    type = map(string)
    default = {
      vnetname = "Vnet-tf"
      public_subnet = "PublicSubnet"      
      private_subnet = "PrivateSubnet"      
    }
}
variable "vnet_cidr" {
  type = string
  # default = ["10.2.0.0/16"]
}
variable "public_subnet_address" {
  default = ["10.2.1.0/24"]
}
variable "private_subnet_address" {
  default = ["10.2.2.0/24"]
}
variable "gateway_subnet_address" {
  default = ["10.2.3.0/24"]
}
variable "bastion_subnet_address" {
  default = ["10.2.4.0/24"]
}

# destination network. Change details.
### --- connection 1, AWS tunnel 1 ----
variable "vpn_gateway_pip_tunnel1" {
  default = "35.157.129.116"
  description = "aws Tunnel1 Outside IP address"
}
variable "asn" {
  default = 64512
  description = "AWS vpn gateway asn"
}
variable "aws_bgp_ip_address_tunnel1" {
  default = "169.254.21.1"
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.21.0/30, AWS will use the BGP IP address 169.254.21.1 and Azure will use the IP address 169.254.21.2"
}
variable "shared_key_tunnel1" {
  default = "yi7KtSGN7.LX9_7CHXEvM9DM.nwDOkp8"
}
    ## --- custom azure bgp configuration ---
variable "custom_apipa_bgp_ip_addresses" {
  default = ["169.254.21.2","169.254.22.2"]
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.21.0/30, AWS will use the BGP IP address 169.254.21.1 and Azure will use the IP address 169.254.21.2"
}
variable "AWSTunnel1ToVPNGWInstance0_primary_custom_bpg_address" {
  default = "169.254.21.2" #used for instance0
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.21.0/30, AWS will use the BGP IP address 169.254.21.1 and Azure will use the IP address 169.254.21.2"
}

# --- connection 1, AWS tunnel 2 ----

variable "vpn_gateway_pip_tunne2" {
  default = "35.157.197.210"
  description = "aws Tunnel2 Outside IP address"
}
variable "aws_bgp_ip_address_tunnel2" {
  default = "169.254.22.1"
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.22.0/30, AWS will use the BGP IP address 169.254.22.1 and Azure will use the IP address 169.254.22.2"
}
variable "shared_key_tunnel2" {
  default = "bJpMALe8_.yPgDdPNLKk6reU8v2uomZl"
}
## --- custom azure bgp configuration ---
variable "AWSTunnel2ToVPNGWInstance0_primary_custom_bpg_address" {
  default = "169.254.22.2" #used for instance0
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.21.0/30, AWS will use the BGP IP address 169.254.21.1 and Azure will use the IP address 169.254.21.2"
}
variable "secondary_custom_bgp_ip_address" {
  default = "169.254.22.6" #not used for instance0
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.22.0/30, AWS will use the BGP IP address 169.254.22.1 and Azure will use the IP address 169.254.22.2"
}


# --- aws s2s connection 2, tunnel 1 ----
variable "connection2_asn" {
  default = 64512
  description = "AWS vpn gateway asn"
}
variable "connection2_vpn_gateway_pip_tunnel1" {
  default = "35.157.197.210"
  description = "aws Tunnel2 Outside IP address"
}
variable "aws_bgp_ip_address_connection2_tunnel1" {
  default = "169.254.22.1"
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.22.0/30, AWS will use the BGP IP address 169.254.22.1 and Azure will use the IP address 169.254.22.2"
}
variable "shared_key_connection2_tunnel1" {
  default = "bJpMALe8_.yPgDdPNLKk6reU8v2uomZl"
}
variable "connection2_custom_apipa_bgp_ip_addresses" {
  default = ["169.254.21.6","169.254.22.6"]
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.21.0/30, AWS will use the BGP IP address 169.254.21.1 and Azure will use the IP address 169.254.21.2"
}
## --- custom azure bgp configuration ---
variable "connection2_AWSTunnel1ToVPNGWInstance1_primary_custom_bpg_address" {
  default = "169.254.21.6" #not used for instance1
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.21.0/30, AWS will use the BGP IP address 169.254.21.1 and Azure will use the IP address 169.254.21.2"
}
variable "connection2_secondary_custom_bgp_ip_address" {
  default = "169.254.22.6" #used for instance1
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.22.0/30, AWS will use the BGP IP address 169.254.22.1 and Azure will use the IP address 169.254.22.2"
}
 
# --- aws s2s connection 2, tunnel 2 ----
variable "connection2_vpn_gateway_pip_tunnel2" {
  default = "35.157.197.210"
  description = "aws Tunnel2 Outside IP address"
}
variable "aws_bgp_ip_address_connection2_tunnel2" {
  default = "169.254.22.1"
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.22.0/30, AWS will use the BGP IP address 169.254.22.1 and Azure will use the IP address 169.254.22.2"
}
variable "shared_key_connection2_tunnel2" {
  default = "bJpMALe8_.yPgDdPNLKk6reU8v2uomZl"
}
## --- custom azure bgp configuration ---
variable "connection2_AWSTunnel2ToVPNGWInstance1_primary_custom_bpg_address" {
  default = "169.254.21.6" #not used for instance1
  description = "AWS bgp ip address. AWS Inside IPv4 CIDR to be 169.254.21.0/30, AWS will use the BGP IP address 169.254.21.1 and Azure will use the IP address 169.254.21.2"
}