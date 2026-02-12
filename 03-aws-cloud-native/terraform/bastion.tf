
## Bastion Host Configuration

data "aws_ami" "ubuntu22" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


## Bastion Host 

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu22.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.Bastion-SG.id]
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = aws_key_pair.EC2_Key_Pair.key_name
  count                  = 1

  tags = {
    Name = "bastion"
  }

  provisioner "file" {

    content     = templatefile("templates/db-init.tmpl", { rds-endpoint = aws_db_instance.RDS.address, dbuser = var.db_user_name, dbpass = var.db_password })
    destination = "/tmp/bastion-setup.sh"

  }

  connection {
      type        = "ssh"
      user        = var.bastion_host_username
      private_key = file(var.priv_key_path)
      host        = self.public_ip
    }
  

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bastion-setup.sh",
      "sudo /tmp/bastion-setup.sh"
    ]
  }



}