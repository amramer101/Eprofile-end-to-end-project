
### Security Group for the Frontend EC2 Instance

resource "aws_security_group" "Frontend-SG" {
  name        = "Frontend-sg"
  description = "Allow SSH and HTTP inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Allow SSH and HTTP"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_frontend" {
  security_group_id = aws_security_group.Frontend-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.Frontend-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_frontend" {
  security_group_id = aws_security_group.Frontend-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}




### Security Group for the Tomcat EC2 Instance

resource "aws_security_group" "Tomcat-SG" {
  name        = "Tomcat-SG"
  description = "Allow 8080 inbound traffic from Frontend and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Allow 8080 from Frontend"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_tomcat" {
  security_group_id = aws_security_group.Tomcat-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_from_frontend" {
  security_group_id            = aws_security_group.Tomcat-SG.id
  referenced_security_group_id = aws_security_group.Frontend-SG.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_tomcat" {
  security_group_id = aws_security_group.Tomcat-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}




