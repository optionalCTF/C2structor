resource "aws_instance" "teamserver" {
  depends_on = [ aws_key_pair.C2structor-keypair ]
  count = var.ts-enabled ? 1 : 0
  ami = data.aws_ami.ubuntu_image.id
  instance_type = var.ts-instance_type
  key_name = var.ssh-keypair-name
  
  # Public access to 80:443/TCP (bad opsec)
  # Restricted access to 22/TCP 
  vpc_security_group_ids = [aws_security_group.sg-internet_access.id, aws_security_group.sg-ssh_access.id]

  root_block_device {
    volume_size = var.ts-storage_size
    volume_type = "gp2"
  }

  tags = {
    Name = "Teamserver"
  }

  provisioner "file" {
    source = var.AP-teamserver-deployment
    destination = "/tmp/ts-playbook.yml"
    
    connection {
      type = "ssh"
      user = var.ssh-user
      private_key = file("${var.ssh-key-location}")
      host = self.public_ip
    }
  }

  
  provisioner "file" {
    source = var.ts-profile
    destination = "/tmp/ts-profile.yaotl"
    
    connection {
      type = "ssh"
      user = var.ssh-user
      private_key = file("${var.ssh-key-location}")
      host = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
    "sudo add-apt-repository --yes --update ppa:ansible/ansible",
    "sudo add-apt-repository --yes --update ppa:longsleep/golang-backports",
    "sudo apt update -y",
    "sudo apt install golang-go software-properties-common ansible -y",
    "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i localhost, -c local /tmp/ts-playbook.yml"
  ]
  
  connection {
    type = "ssh"
    user = var.ssh-user
    private_key = file("${var.ssh-key-location}")
    host = self.public_ip
  }
}
}