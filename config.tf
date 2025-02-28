terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "sg-ssh_access" {
  name = "ssh-access-sg"
  description = "Allow SSH access to resources"

  ingress {
    description = "SSH from authorised IP"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.authorised_ip_block}" ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-access-sg"
  }
}

resource "aws_security_group" "sg-internet_access" {
  name = "internet_access"
  description = "Allow internet access on 443/80"

  ingress {
    description = "Internet on 443"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "Internet on 80"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    description = "Allow all outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "private_key" {
  content = tls_private_key.ssh_key.private_key_pem
  filename = var.ssh-key-location
  file_permission = "0600"
}

resource "aws_key_pair" "C2structor-keypair" {
  key_name = var.ssh-keypair-name
  public_key = tls_private_key.ssh_key.public_key_openssh
}