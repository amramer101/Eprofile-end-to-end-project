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


