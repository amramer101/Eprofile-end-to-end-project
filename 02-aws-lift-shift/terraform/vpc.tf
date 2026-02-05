module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.VPC_Name
  cidr = var.VPC_CIDR

  azs             = [var.AWS_Zone-a, var.AWS_Zone-b, var.AWS_Zone-c]
  private_subnets = var.Private_Subnet_CIDR
  public_subnets  = var.Public_Subnet_CIDR

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}