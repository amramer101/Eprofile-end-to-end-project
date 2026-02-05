### EC2 Instance for Nginx Server

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Nginx-instance"

  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ami                         = "ami-01f79b1e4a5c64257" # eu-central-1 ubuntu 20.24.04 LTS
  vpc_security_group_ids      = [aws_security_group.Frontend-SG.id]
  key_name                    = aws_key_pair.EC2_Key_Pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = file("../../01-local-setup/Automated-Setup/nginx.sh")

}

### EC2 Instance for Tomcat Server