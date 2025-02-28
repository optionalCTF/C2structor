# C2structor
C2structor aims to optimise and reduce overhead in relation to infrastructure deployment for red team engagements. In it's current state infrastructure is deployed onto AWS using Terraform and Ansible playbooks while providing a relatively straight-forward user experience by controlling deployment through the `terraform.tfvars` file. For full capabilities see below.


It should be noted at this point that IOCs have been left intact. Additionally, although security groups are generated and assigned, they have not been configured with OPSEC in mind with the exception to restricting SSH access to an authorised IP range (such as a VPN). The generated security groups should be reviewed and restricted appropriately. 


## Capabilities
- Havoc C2 deployment hosted behind a CloudFront Edge Redirector and Caddy internal Redirector
- Gophish server deployment
- Evilginx2 server deployment

It should be noted that the Evilginx2 deployment will create an EC2 instance with Evilginx2 built in `/opt/evilginx2/build/evilginx`, this is by design as each configuration should be tailored to your engagement rather than using a boiler plate configuration.

For full automated deployment of CloudFront, a Route53 domain is required. Though an option exists to disable Route53, this would result in additional configuration on the operators end.

## Requirements
- Terraform
- AWS CLI
- AWS IAM user with capabilities to deploy resources


## Deployment
C2structor can be configured and deployed with the following steps

### Clone the Repo
```
$ git clone https://github.com/optionalCTF/C2structor.git
$ cd C2structor
```

### Configure Deployment
C2structor is controlled through the `terraform.tfvars` configuration file. Here you can specify which resources you would like to deploy as well as specify Route53 Hosted Zones, domain names and preferred sub-domain.
Example Configuration
```
# Deploy Gophish Server (Default disabled)
gophish_enabled = false

# Deploy Evilginx Server (Default disabled)
evilginx_enabled = false

# Deploy Teamserver and redirectors (Default true)
ts-enabled = true

# Authorised IP for SSH Access (Expects CIDR block e.g 8.8.8.8/32)
authorised_ip_block = "8.8.8.8/32"
```
If a teamserver is being deployed, you will need to toggle Route53 (default is enabled) and specify the domain and subdomain for the CloudFront origin.
If Route53 is in-use, you will also need to specify the Hosted Zone ID to allow dynamic DNS records. 

### Initialise Terraform
```
$ terraform init
$ terraform plan 
$ terraform apply
```

Once Terraform has deployed your resources, outputs will go into `/outputs`, this will contain the SSH key for setting up local forwarding and if Gophish was deployed, the admin credentials to login.

## Disclaimer
C2structor is designed to aid deployment but will require manual modifications to remove IOCs, it is also recommended that manual adjustments are made to security groups to restrict public access to resources where necessary. IOCs were left by design and security groups are purposely lax to prevent blatant abuse.

