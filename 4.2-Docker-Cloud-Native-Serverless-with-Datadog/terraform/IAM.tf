# Trust policy for ECS tasks
data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create the task execution role
resource "aws_iam_role" "ecs_execution" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json

  tags = {
    Service   = "ecs"
    ManagedBy = "terraform"
  }
}

# Attach the AWS managed execution role policy
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Additional policy for accessing secrets during container startup
resource "aws_iam_policy" "ecs_execution_secrets" {
  name        = "ecs-execution-secrets-access"
  description = "Allow ECS execution role to retrieve secrets for container environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Read secrets from Secrets Manager
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = [
          "arn:aws:secretsmanager${data.aws_region.current.name}:*:secret:/strata-ops/*",
        ]
      },
      {
        # Read parameters from SSM Parameter Store
        Sid    = "SSMParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
        ]
        Resource = [
          "arn:aws:ssm:eu-central-1:*:parameter/strata-ops/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_execution_secrets.arn
}