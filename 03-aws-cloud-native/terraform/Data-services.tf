resource "aws_db_subnet_group" "RDS_subnet_group" {
  name       = "RDS_subnet_group"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]

  tags = {
    Name = "DB subnet group"
  }
}


resource "aws_db_instance" "RDS" {
  allocated_storage      = 20
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  username               = var.db_user_name
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.RDS_subnet_group.name
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.Data-SG.id]
}