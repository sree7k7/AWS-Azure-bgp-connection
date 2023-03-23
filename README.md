# aws - azure bgp enabled connection

This guide helps on implementing bgp-enabled vpn connection between AWS and Azure.

- A simplified way of this [article](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-aws-bgp) in Terraform (widely used with slow pace).

- The scripts are in cd.and terraform:
  - - On AWS side in  [CDK](https://github.com/sree7k7/AWS-multi-S2S) (python)
  - - Azure side in [terraform](https://developer.hashicorp.com/terraform/tutorials/azure-get-started).

## Run

- Purpose
- Execute scripts
- Configuration
- Verify the connection

![AWS-Azure](pic/AWS-Azure-design.png)

## Prerequsites

- AWS in [CDK](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html)
- Azure in [terraform](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)
- [azure cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) & [sign in](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)

## Purpose

To connect mulitple (aws) tunnels/sites for redundancy with active-active enabled azure vpn gateway.
And to avoid active-passive connection with one custom BGP ip on azure vpn gateway.

## Execute scripts

Azure

1. Clone [this](https://github.com/sree7k7/AWS-Azure-bgp-connection) and deploy the code as it is (using terraform). Later, change the parameters (ip's).

2. execute below cmds:

- terraform init
- terraform plan
- terraform apply

**Note**: If fails, try to execute: **terraform init -upgrade** on terminal and execute cmd: **terraform apply --auto-approve**.

- Copy the public ip's of vpn gateway for instanc0, 1.
- Copy the ASN.
![Azure-vpn-gateway-active-active-mode](pic/azure-vpn-gateway.png)

AWS

3. Clone [this](https://github.com/sree7k7/AWS-multi-S2S) repo and deploy.

4. Execute the following commands in terminal.

```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

- In parameters.py file change the ip's. *VPNGWinstance0_pip* and
*VPNGWinstance1_pip*

```
# AWS VPC
regionName = "eu-west-1"
vpc_cidr = "10.3.0.0/16"
cidr_mask = 24
VPNconnetion1Tunnel1 = "169.254.21.0/30"
VPNconnetion1Tunnel2 = "169.254.22.0/30"

VPNconnetion2Tunnel1 = "169.254.21.4/30"
VPNconnetion2Tunnel2 = "169.254.22.4/30"      

# destination network
VPNGWinstance0_pip = "20.105.96.150"
VPNGWinstance1_pip = "20.105.96.15"
destinationCIDR = "10.2.0.0/16"
```
