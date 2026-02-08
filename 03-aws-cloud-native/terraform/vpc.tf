module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.VPC_Name
  cidr = var.VPC_CIDR

  azs             = [var.AWS_Zone-a, var.AWS_Zone-b, var.AWS_Zone-c]
  private_subnets = var.Private_Subnet_CIDR
  public_subnets  = var.Public_Subnet_CIDR


  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_vpn_gateway      = false
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true
  enable_dns_support      = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# 1. Create Private Hosted Zone

resource "aws_route53_zone" "private_zone" {
  name = "eprofile.in"

  vpc {
    vpc_id = module.vpc.vpc_id
  }

}

## 2. Create Record for Database
resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "db01.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_mysql.private_ip]
}

# 3. Create Record for Memcached
resource "aws_route53_record" "mc" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "mc01.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_memcache.private_ip]
}

# 4. Create Record for RabbitMQ
resource "aws_route53_record" "rmq" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "rmq01.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_rabbitmq.private_ip]
}

# 5. Create Record for Tomcat
resource "aws_route53_record" "tomcat" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "app01.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_tomcat.private_ip]
}

