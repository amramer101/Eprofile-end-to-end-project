## search for ubuntu22 ami 

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



##--------------------------------------------------------------------------------------------------------------

### EC2 Instance for Nginx Server

module "ec2_instance_nginx" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Nginx-instance"

  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu22.id
  vpc_security_group_ids      = [aws_security_group.Frontend-SG.id]
  key_name                    = aws_key_pair.EC2_Key_Pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[1]
  create_security_group       = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = file("../userdata-EC2/nginx.sh")

}


### EC2 Instance for Tomcat Server

module "ec2_instance_tomcat" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Tomcat-instance"

  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu22.id
  vpc_security_group_ids      = [aws_security_group.Tomcat-SG.id]
  key_name                    = aws_key_pair.EC2_Key_Pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[1]
  create_security_group       = false


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data            = file("../userdata-EC2/tomcat_ubuntu.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name


}


#### EC2 Instance for rappitmq Server

module "ec2_instance_rabbitmq" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "RabbitMQ-instance"

  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu22.id
  vpc_security_group_ids = [aws_security_group.Data-SG.id]
  key_name               = aws_key_pair.EC2_Key_Pair.key_name
  monitoring             = false
  subnet_id              = module.vpc.private_subnets[1]
  create_security_group  = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = file("../userdata-EC2/rabbitmq.sh")

}

### EC2 Instance for Memcache Server

module "ec2_instance_memcache" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Memcache-instance"

  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu22.id
  vpc_security_group_ids = [aws_security_group.Data-SG.id]
  key_name               = aws_key_pair.EC2_Key_Pair.key_name
  monitoring             = false
  subnet_id              = module.vpc.private_subnets[2]
  create_security_group  = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data = file("../userdata-EC2/memcache.sh")

}


### EC2 Instance for MySQL Server

module "ec2_instance_mysql" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "MySQL-instance"

  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu22.id
  vpc_security_group_ids = [aws_security_group.Data-SG.id]
  key_name               = aws_key_pair.EC2_Key_Pair.key_name
  monitoring             = false
  subnet_id              = module.vpc.private_subnets[2]
  create_security_group  = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data            = file("../userdata-EC2/mysql.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name


}

#### ---------------------------------------------------------------------------------------

### EC2 Instance for Jenkins Server

module "ec2_instance_Jenkins" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-instance"

  instance_type               = "t2.medium"
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu22.id
  vpc_security_group_ids      = [aws_security_group.jenkins-SG.id]
  key_name                    = aws_key_pair.ci_key_pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]
  create_security_group       = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data            = file("../userdata-EC2/jenkins.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  depends_on           = [module.ec2_instance_nexus, module.ec2_instance_sonarqube]

}


### EC2 Instance for sonar Server

module "ec2_instance_sonarqube" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "sonar-instance"

  instance_type               = "t2.medium"
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu22.id
  vpc_security_group_ids      = [aws_security_group.sonar-SG.id]
  key_name                    = aws_key_pair.ci_key_pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]
  create_security_group       = false


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data            = file("../userdata-EC2/sonar.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

}


#### EC2 Instance for nexus Server

module "ec2_instance_nexus" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus-instance"

  instance_type          = "t2.medium"
  ami                    = data.aws_ami.ubuntu22.id
  vpc_security_group_ids = [aws_security_group.nexus-SG.id]
  key_name               = aws_key_pair.ci_key_pair.key_name
  monitoring             = false
  subnet_id              = module.vpc.public_subnets[0]
  create_security_group  = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data            = file("../userdata-EC2/nexus.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

}

#### ---------------------------------------------------------------------------------------


### EC2 Instance for Prometheus Server

module "ec2_instance_prometheus" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "prometheus-instance"

  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu22.id
  vpc_security_group_ids = [aws_security_group.prometheus-SG.id]
  key_name               = aws_key_pair.monitor_key_pair.key_name
  monitoring             = false
  subnet_id              = module.vpc.public_subnets[1]
  create_security_group  = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data            = file("../userdata-EC2/setup-prometheus.sh")

  depends_on = [module.ec2_instance_tomcat, module.ec2_instance_mysql, module.ec2_instance_nginx]

}


### EC2 Instance for Grafana Server

module "ec2_instance_grafana" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "grafana-instance"

  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu22.id
  vpc_security_group_ids = [aws_security_group.Grafana-SG.id]
  key_name               = aws_key_pair.monitor_key_pair.key_name
  monitoring             = false
  subnet_id              = module.vpc.public_subnets[1]
  create_security_group  = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  user_data            = file("../userdata-EC2/Grafana.sh")
  
  depends_on = [module.ec2_instance_prometheus]

}
