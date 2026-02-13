
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

  #### Provisioning the Bastion Host with the RDS endpoint and credentials
  # Updated to use templatefile with corrected variable names
  user_data = base64encode(templatefile("${path.module}/templates/bastion-init.sh", {
    RDS_ENDPOINT = aws_db_instance.RDS.address
    DB_USER      = var.db_user_name
    DB_PASSWORD  = var.db_password
    DB_NAME      = var.db_name
  }))

  depends_on = [aws_db_instance.RDS]
}