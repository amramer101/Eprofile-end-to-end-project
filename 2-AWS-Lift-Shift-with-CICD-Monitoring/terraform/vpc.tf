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

# 6. Create Record for nginx
resource "aws_route53_record" "nginx" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "nginx.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_nginx.private_ip]
}

## 7. Create Record for Nexus
resource "aws_route53_record" "Nexus" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "nexus.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_nexus.private_ip]
}

# 8. Create Record for Jenkins
resource "aws_route53_record" "Jenkins" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "jenkins.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_Jenkins.private_ip]
}

# 9. Create Record for SonarQube
resource "aws_route53_record" "SonarQube" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "sonarqube.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_sonarqube.private_ip]
}

# 10. Create Record for Prometheus
resource "aws_route53_record" " prometheus" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "prometheus.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_prometheus.private_ip]
}

# 11. Create Record for grafana
resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "grafana.eprofile.in"
  type    = "A"
  ttl     = "300"
  records = [module.ec2_instance_grafana.private_ip]
}
