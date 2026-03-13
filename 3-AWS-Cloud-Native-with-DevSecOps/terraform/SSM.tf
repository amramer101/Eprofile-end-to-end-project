resource "random_password" "db_password" {
  length  = 8
  special = false
}

resource "aws_ssm_parameter" "mysql_password" {
  name  = "/strata-ops/mysql-password"
  type  = "SecureString"
  value = random_password.db_password.result
}


resource "random_password" "rmq_password" {
  length  = 12
  special = false
}

resource "aws_ssm_parameter" "rabbitmq_password" {
  name  = "/strata-ops/rabbitmq-password"
  type  = "SecureString"
  value = random_password.rmq_password.result
}

resource "aws_ssm_parameter" "sonar_token" {
  name  = "/strata-ops/sonar-token"
  type  = "SecureString"
  value = var.sonar_token
}

resource "aws_ssm_parameter" "sonar_org" {
  name  = "/strata-ops/sonar-org"
  type  = "String"
  value = var.sonar_organization
}

resource "aws_ssm_parameter" "sonar_project" {
  name  = "/strata-ops/sonar-project"
  type  = "String"
  value = var.sonar_project_key
}
