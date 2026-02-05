module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "Nginx-instance"

  instance_type = "t3.micro"
  associate_public_ip_address = true
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  key_name      = "user1"
  monitoring    = true
  subnet_id     = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
