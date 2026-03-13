# -----------------------------------------------------------
# 1. Role for CodeBuild --- Build Stage
# -----------------------------------------------------------
resource "aws_iam_role" "codebuild_build_role" {
  name = "vprofile-codebuild-build-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_build_policy" {
  name = "vprofile-build-policy"
  role = aws_iam_role.codebuild_build_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },

      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.codepipeline_bucket.arn,
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },

      {
        Effect = "Allow"
        Action = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ReadFromRepository"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sts:GetServiceBearerToken"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      },

      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = aws_codestarconnections_connection.github_connection.arn
      }
    ]
  })
}


# -----------------------------------------------------------
# 2. Role for CodeBuild --- Security Stage
# -----------------------------------------------------------

resource "aws_iam_role" "codebuild_security_role" {
  name = "vprofile-codebuild-security-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}


resource "aws_iam_role_policy" "codebuild_security_policy" {
  name = "vprofile-security-policy"
  role = aws_iam_role.codebuild_security_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      # 2. S3 (Pipeline Bucket)
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.codepipeline_bucket.arn,
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },
      # 3. SSM Parameter Store
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/strata-ops/sonar-*"
      },
      # 4. CodeArtifact
      {
        Effect = "Allow"
        Action = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ReadFromRepository"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sts:GetServiceBearerToken"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      },
      # 5. GitHub Connection
      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = aws_codestarconnections_connection.github_connection.arn
      }
    ]
  })
}

# -----------------------------------------------------------
# 3. Role for CodePipeline
# -----------------------------------------------------------
resource "aws_iam_role" "codepipeline_role" {
  name = "vprofile-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "vprofile-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["elasticbeanstalk:*"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:*",
          "codestar-connections:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "sns:*",
          "logs:*",
          "cloudformation:*",
          "rds:*"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
      }
    ]
  })
}