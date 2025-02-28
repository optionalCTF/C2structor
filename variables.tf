# Update for dynamic modifications
# --------------------------------
# --------------------------------
# --------------------------------

# General Configuration
variable "aws_region" {
    description = "AWS region for deployment"
    type = string
}

variable "r53-domain" {
  description = "Is Route53 in use"
  type = bool
  default = true
}

variable "authorised_ip_block" {
  description = "IP block for authorised SSH access"
  type = string
}

# TeamServer Configuration
variable "ts-enabled" {
  description = "How many teamservers do you need to deploy"
  type = bool
  default = true # Update value for teamservers 
  
}

# Teamserver profile
variable "ts-profile" {
  description = "teamserver profile"
  type = string
  default = "./profiles/ts-profile.yaotl"
}

variable "ts-storage_size" {
  description = "Size of EBS"
  type = number
  default = 15 # Adjust to requirement, 15 is low for testing purposes
}

variable "ts-instance_type" {
  description = "EC2 instance type"
  type = string
  # t3.micro is recommended as a minimum
  default = "t3.micro"
}

variable "redirector-domain" {
  description = "domain name to use"
  type = string
}

variable "redirector-subdomain" {
  description = "sub-domain for redirector"
  type = string
  default = "update"
}

variable "redirector-zoneid" {
  description = "Route53 Zone ID"
  type = string
}

variable "gophish_enabled" {
  description = "Deploy Gophish server"
  type = bool
  default = false
}

variable "evilginx_enabled" {
  description = "Deploy evilginx server"
  type = bool
  default = false
}

# Static Variables
# --------------------------------
# --------------------------------
# --------------------------------
# Playbooks

variable "AP-teamserver-deployment" {
  description = "Path to playbook for teamserver deployment"
  type = string
  default = "./ansible/ts-playbook.yml"
}

variable "AP-gophish-deployment" {
  description = "Path to playbook for teamserver deployment"
  type = string
  default = "./ansible/gophish-playbook.yml"
}

variable "AP-evilginx-deployment" {
  type = string
  default = "./ansible/evilginx-playbook.yml"
}

variable "ssh-user" {
  description = "SSH user"
  type = string
  default = "ubuntu"
}

# Ubuntu image
data "aws_ami" "ubuntu_image" {
    most_recent = true
    owners = ["099720109477"] # canonical's AWS ID

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

variable "ssh-keypair-name" {
  description = "Name for SSH Keypair"
  type = string
  default = "C2structor"
}

variable "ssh-key-location" {
  description = "SSH private key location"
  type = string
  default = "./outputs/C2structor.pem"
}



