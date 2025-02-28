resource "aws_instance" "gophish-server" {
  depends_on = [ aws_key_pair.C2structor-keypair ]
  count = var.gophish_enabled ? 1 : 0 
  ami = data.aws_ami.ubuntu_image.id
  instance_type = "t2.micro"
  key_name = var.ssh-keypair-name
  vpc_security_group_ids = [ aws_security_group.sg-ssh_access.id ]

  tags = {
    Name = "Gophish-Server"
  }

   provisioner "file" {
      source = var.AP-gophish-deployment
      destination = "/tmp/gophish-playbook.yml"
      
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
    "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i localhost, -c local /tmp/gophish-playbook.yml",
    "sleep 15",
    "grep 'Please login with' /var/log/gophish.log | sudo tee /tmp/gophish_password.txt"
  ]
  
  connection {
    type = "ssh"
    user = var.ssh-user
    private_key = file("${var.ssh-key-location}")
    host = self.public_ip
  }
}
provisioner "local-exec" {
   command = "scp -o StrictHostKeyChecking=accept-new -i ${var.ssh-key-location} ${var.ssh-user}@${self.public_ip}:/tmp/gophish_password.txt ./outputs/gophish_pw.txt"
  }
  
}


# Evilginx 2 setup

resource "aws_instance" "evilginx-server" {
  depends_on = [ aws_key_pair.C2structor-keypair ]
  count = var.evilginx_enabled ? 1 : 0
  ami = data.aws_ami.ubuntu_image.id
  instance_type = "t2.micro"
  key_name = var.ssh-keypair-name
  vpc_security_group_ids = [ aws_security_group.sg-ssh_access.id ]

  tags = {
    Name = "Evilginx-Server"
  }

   provisioner "file" {
      source = var.AP-evilginx-deployment
      destination = "/tmp/evilginx-playbook.yml"
      
      connection {
        type = "ssh"
        user = "ubuntu"
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
    "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i localhost, -c local /tmp/evilginx-playbook.yml",
  ]
  
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("${var.ssh-key-location}")
    host = self.public_ip
  }
}
}