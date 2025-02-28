# AWS region
aws_region = "eu-west-2"

# SSH keypair name (Default C2structor)
ssh-keypair-name = "C2structor"

# SSH keypair location
ssh-key-location = "./outputs/C2structor.pem"

# Route 53 in use. 
# If set to true, ensure route 53 zone id is set for the domain
# If false, ensure redirector sub domain and domain are set as it will use this instead
r53-domain = true

# route 53 zone id for root domain
redirector-zoneid = ""

# Root domain for redirector
redirector-domain = ""

# sub-domain for redirector
redirector-subdomain = ""


# Deploy Gophish Server (Default disabled)
gophish_enabled = true

# Deploy Evilginx Server (Default disabled)
evilginx_enabled = true

# Deploy Teamserver and redirectors (Default true)
ts-enabled = true

# Authorised IP for SSH Access (Expects CIDR block e.g 8.8.8.8/32)
authorised_ip_block = ""
