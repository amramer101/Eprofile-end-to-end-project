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
  length  = 8
  special = false
}

resource "aws_ssm_parameter" "rabbitmq_password" {
  name  = "/strata-ops/rabbitmq-password"
  type  = "SecureString"
  value = random_password.rmq_password.result
}
 