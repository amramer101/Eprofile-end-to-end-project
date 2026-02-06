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

module "ec2_instance_tomcat" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Tomcat-instance"

  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ami                         = "ami-01f79b1e4a5c64257" # eu-central-1 ubuntu 20.24.04 LTS
  vpc_security_group_ids      = [aws_security_group.Tomcat-SG.id]
  key_name                    = aws_key_pair.EC2_Key_Pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = file("../../01-local-setup/Automated-Setup/tomcat_ubuntu.sh")

}


#### EC2 Instance for rappitmq Server

module "ec2_instance_rabbitmq" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "RabbitMQ-instance"

  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ami                         = "ami-0532be01f26a3de55" # eu-central-1 AWS Linux 2
  vpc_security_group_ids      = [aws_security_group.Data-SG.id]
  key_name                    = aws_key_pair.EC2_Key_Pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.private_subnets[1]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = file("../../01-local-setup/Automated-Setup/rabbitmq.sh")

}

### EC2 Instance for Memcache Server

module "ec2_instance_memcache" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Memcache-instance"

  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ami                         = "ami-0532be01f26a3de55" # eu-central-1 AWS Linux 2
  vpc_security_group_ids      = [aws_security_group.Data-SG.id]
  key_name                    = aws_key_pair.EC2_Key_Pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.private_subnets[2]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = file("../../01-local-setup/Automated-Setup/memcache.sh")

}


### EC2 Instance for MySQL Server

module "ec2_instance_mysql" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "MySQL-instance"

  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ami                         = "ami-0532be01f26a3de55" # eu-central-1 AWS Linux 2
  vpc_security_group_ids      = [aws_security_group.Data-SG.id]
  key_name                    = aws_key_pair.EC2_Key_Pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.private_subnets[2]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = file("../../01-local-setup/Automated-Setup/mysql.sh")

}

