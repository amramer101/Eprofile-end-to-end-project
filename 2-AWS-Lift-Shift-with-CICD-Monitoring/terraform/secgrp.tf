data "http" "my_public_ip" {
  url = "http://checkip.amazonaws.com/"
}

locals {
  # Use chomp() to remove any trailing newlines or whitespace
  my_public_ip_cidr = "${chomp(data.http.my_public_ip.response_body)}/32"
}

#####------------------------------------------------------------------------------------------------------------------

### Security Group for the Frontend EC2 Instance

resource "aws_security_group" "Frontend-SG" {
  name        = "Frontend-sg"
  description = "Allow SSH and HTTP inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Frontend-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_frontend" {
  security_group_id = aws_security_group.Frontend-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
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


resource "aws_vpc_security_group_ingress_rule" "allow_9100_from_prometheus-SG_frontend" {
  security_group_id            = aws_security_group.Frontend-SG.id
  referenced_security_group_id = aws_security_group.prometheus-SG.id
  from_port                    = 9100
  ip_protocol                  = "tcp"
  to_port                      = 9100
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
    Name = "Tomcat-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_tomcat" {
  security_group_id            = aws_security_group.Tomcat-SG.id
  referenced_security_group_id = aws_security_group.jenkins-SG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_tomcat_from_my_ip" {
  security_group_id = aws_security_group.Tomcat-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
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


resource "aws_vpc_security_group_ingress_rule" "allow_9100_from_prometheus-SG_tomcat" {
  security_group_id            = aws_security_group.Tomcat-SG.id
  referenced_security_group_id = aws_security_group.prometheus-SG.id
  from_port                    = 9100
  ip_protocol                  = "tcp"
  to_port                      = 9100
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_tomcat" {
  security_group_id = aws_security_group.Tomcat-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}




### Security Group for the Data EC2s Instance

resource "aws_security_group" "Data-SG" {
  name        = "Data-SG"
  description = "Allow 3306, 11211, 5672 inbound traffic from tomcat and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Data-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_Data" {
  security_group_id = aws_security_group.Data-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
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

resource "aws_vpc_security_group_ingress_rule" "allow_5672_from_tomcat-SG" {
  security_group_id            = aws_security_group.Data-SG.id
  referenced_security_group_id = aws_security_group.Tomcat-SG.id
  from_port                    = 5672
  ip_protocol                  = "tcp"
  to_port                      = 5672
}


resource "aws_vpc_security_group_ingress_rule" "allow_9100_from_prometheus-SG_Data" {
  security_group_id            = aws_security_group.Data-SG.id
  referenced_security_group_id = aws_security_group.prometheus-SG.id
  from_port                    = 9100
  ip_protocol                  = "tcp"
  to_port                      = 9100
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_Data" {
  security_group_id = aws_security_group.Data-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


##### ---------------------------------------------------------------------------------------------------------------------------


### Security Group for the jenkins EC2 Instance

resource "aws_security_group" "jenkins-SG" {
  name        = "jenkins-sg"
  description = "Allow SSH and 8080 inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "jenkins-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_jenkins" {
  security_group_id = aws_security_group.jenkins-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_jenkins" {
  security_group_id = aws_security_group.jenkins-SG.id
  cidr_ipv4         = "0.0.0.0/0" ## To connect to GitHub and SonarQube Webhooks, Jenkins needs to be accessible from the internet on port 8080. In production, consider using a more secure approach such as a reverse proxy or API Gateway. --- IGNORE ---
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_jenkins" {
  security_group_id = aws_security_group.jenkins-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}




### Security Group for the sonar EC2 Instance

resource "aws_security_group" "sonar-SG" {
  name        = "sonar-SG"
  description = "Allow ssh and 80 inbound traffic from Frontend and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "sonar-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_sonar" {
  security_group_id = aws_security_group.sonar-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_ingress_rule" "allow_80_sonar" {
  security_group_id = aws_security_group.sonar-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_sonar" {
  security_group_id = aws_security_group.sonar-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}




### Security Group for the nexus EC2s Instance

resource "aws_security_group" "nexus-SG" {
  name        = "nexus-SG"
  description = "Allow 22 and 8081 ffic from tomcat and all outbound traffic"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "nexus-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_nexus" {
  security_group_id = aws_security_group.nexus-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_ingress_rule" "allow_8081_from_nexus" {
  security_group_id = aws_security_group.nexus-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8081
  ip_protocol       = "tcp"
  to_port           = 8081
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_nexus" {
  security_group_id = aws_security_group.nexus-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


##### ---------------------------------------------------------------------------------------------------------------------------

#### Security Group for the Prometheus EC2s Instance

resource "aws_security_group" "prometheus-SG" {
  name        = "prometheus-SG"
  description = "Allow ssh and 9090 inbound traffic from Frontend and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "prometheus-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_prometheus" {
  security_group_id = aws_security_group.prometheus-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_ingress_rule" "allow_9090_prometheus" {
  security_group_id = aws_security_group.prometheus-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 9090
  ip_protocol       = "tcp"
  to_port           = 9090
}

resource "aws_vpc_security_group_ingress_rule" "allow_9090_from_grafana-SG_prometheus" {
  security_group_id            = aws_security_group.prometheus-SG.id
  referenced_security_group_id = aws_security_group.Grafana-SG.id
  from_port                    = 9090
  ip_protocol                  = "tcp"
  to_port                      = 9090
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_prometheus" {
  security_group_id = aws_security_group.prometheus-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



## ### Security Group for the Grafana EC2s Instance


resource "aws_security_group" "Grafana-SG" {
  name        = "Grafana-SG"
  description = "Allow ssh and 3000 inbound traffic from Frontend and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Grafana-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_grafana" {
  security_group_id = aws_security_group.Grafana-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_ingress_rule" "allow_3000_grafana" {
  security_group_id = aws_security_group.Grafana-SG.id
  cidr_ipv4         = local.my_public_ip_cidr
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_grafana" {
  security_group_id = aws_security_group.Grafana-SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
