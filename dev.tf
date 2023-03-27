
module "module_dev" {
  source = "./modules"
  resource_group_location = "northeurope"
  vnet_cidr = "10.2.0.0/16"
  public_subnet_address = "10.2.1.0/24"
  private_subnet_address = "10.2.2.0/24"
  gateway_subnet_address = "10.2.3.0/24"
  bastion_subnet_address = "10.2.4.0/24"

# destination network - S2S connection 1. Change details.
### --- AWS tunnel 1 ----
  vpn_gateway_pip_tunnel1 = "18.194.108.179"
  asn = "64512"
  aws_bgp_ip_address_tunnel1 = "169.254.21.1"
  shared_key_tunnel1 = "UIb4LhzcgjOrDPjQokAqkijwfrM6pqQg"
  custom_apipa_bgp_ip_addresses = ["169.254.21.2","169.254.22.2"]
  AWSTunnel1ToVPNGWInstance0_primary_custom_bpg_address = "169.254.21.2"
### --- AWS tunnel 2 ----
  vpn_gateway_pip_tunne2 = "52.28.228.231"
  aws_bgp_ip_address_tunnel2 = "169.254.22.1"
  shared_key_tunnel2 = "m_dKrd2F4vIx.TqLuaGlbXR.U5NgU0yd"
  AWSTunnel2ToVPNGWInstance0_primary_custom_bpg_address = "169.254.22.2"
  secondary_custom_bgp_ip_address = "169.254.22.6"


# destination network - S2S connection 2. Change details.
### --- AWS tunnel 1 ----
  connection2_asn = "64512"
  connection2_vpn_gateway_pip_tunnel1 = "3.67.246.6"
  aws_bgp_ip_address_connection2_tunnel1 = "169.254.21.5"
  shared_key_connection2_tunnel1 = "GSy3WlBYY6ni9wqMSD90H8NHBSgyLf8h"
  connection2_custom_apipa_bgp_ip_addresses = ["169.254.21.6","169.254.22.6"]
  connection2_AWSTunnel1ToVPNGWInstance1_primary_custom_bpg_address = "169.254.21.2"
### --- AWS tunnel 2 ----
  connection2_vpn_gateway_pip_tunnel2 = "3.69.201.243"
  aws_bgp_ip_address_connection2_tunnel2 = "169.254.22.5"
  shared_key_connection2_tunnel2 = "3_M6ncU_o2xj0EoM7I_Vs6.BQPJsM7cX"
  connection2_AWSTunnel2ToVPNGWInstance1_primary_custom_bpg_address = "169.254.22.2"
  connection2_secondary_custom_bgp_ip_address = "169.254.22.6"
}