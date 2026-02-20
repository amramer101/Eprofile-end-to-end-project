data "http" "my_public_ip" {
  url = "http://checkip.amazonaws.com/"
}

locals {
  # Use chomp() to remove any trailing newlines or whitespace
  my_public_ip_cidr = "${chomp(data.http.my_public_ip.response_body)}/32"
}



### Security Group for the Frontend EC2 Instance

resource "aws_security_group" "Load-Balancer-SG" {
  name        = "Load-Balancer-SG"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Load-Balancer-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.Load-Balancer-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_frontend" {
  security_group_id = aws_security_group.Load-Balancer-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

####---------------------------------------------------------------------------------------------

### Security Group for the Tomcat EC2 Instance

resource "aws_security_group" "Tomcat-SG" {
  name        = "Tomcat-SG"
  description = "Allow 80 inbound traffic from Frontend and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Tomcat-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_tomcat" {
  security_group_id = aws_security_group.Tomcat-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_from_frontend" {
  security_group_id            = aws_security_group.Tomcat-SG.id
  referenced_security_group_id = aws_security_group.Load-Balancer-SG.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_tomcat" {
  security_group_id = aws_security_group.Tomcat-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

####---------------------------------------------------------------------------------------------

### Security Group for the Data EC2s Instance

resource "aws_security_group" "Data-SG" {
  name        = "Data-SG"
  description = "Allow 3306, 11211, 5672 inbound traffic from tomcat and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Data-SG"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_3306_from_tomcat-SG" {
  security_group_id            = aws_security_group.Data-SG.id
  referenced_security_group_id = aws_security_group.Tomcat-SG.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow_11211_from_tomcat-SG" {
  security_group_id            = aws_security_group.Data-SG.id
  referenced_security_group_id = aws_security_group.Tomcat-SG.id
  from_port                    = 11211
  ip_protocol                  = "tcp"
  to_port                      = 11211
}

resource "aws_vpc_security_group_ingress_rule" "allow_5671_from_tomcat-SG" {
  security_group_id            = aws_security_group.Data-SG.id
  referenced_security_group_id = aws_security_group.Tomcat-SG.id
  from_port                    = 5672
  ip_protocol                  = "tcp"
  to_port                      = 5672
}

resource "aws_vpc_security_group_ingress_rule" "allow_3306_from_Bastion" {
  security_group_id            = aws_security_group.Data-SG.id
  referenced_security_group_id = aws_security_group.Bastion-SG.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow_ipv4_internal" {
  security_group_id            = aws_security_group.Data-SG.id
  referenced_security_group_id = aws_security_group.Data-SG.id
  from_port                    = 0
  ip_protocol                  = "tcp"
  to_port                      = 65535
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_Data" {
  security_group_id = aws_security_group.Data-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


####---------------------------------------------------------------------------------------------

### Security Group for the Bastion EC2s Instance

resource "aws_security_group" "Bastion-SG" {
  name        = "Bastion-SG"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Bastion-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_Bastion" {
  security_group_id = aws_security_group.Bastion-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_Bastion" {
  security_group_id = aws_security_group.Bastion-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

