# -----------------------------------------------------------
# 1. Role for CodeBuild (صلاحيات كاملة لعملية البناء)
# -----------------------------------------------------------
resource "aws_iam_role" "codebuild_role" {
  name = "vprofile-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "vprofile-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # صلاحيات كاملة لكل شيء يحتاجه Build (Logs, S3, EC2)
        Effect   = "Allow"
        Action   = ["*"]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------
# 2. Role for CodePipeline (صلاحيات كاملة لإدارة خط الإنتاج والرفع)
# -----------------------------------------------------------
resource "aws_iam_role" "codepipeline_role" {
  name = "vprofile-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
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
      # 1. القضاء على مشاكل S3 نهائياً (بما فيها DeleteObject و GetBucketPolicy)
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = "*"
      },
      # 2. القضاء على مشاكل Elastic Beanstalk نهائياً
      {
        Effect   = "Allow"
        Action   = ["elasticbeanstalk:*"]
        Resource = "*"
      },
      # 3. صلاحيات كاملة لـ CodeBuild و CodeStar
      {
        Effect   = "Allow"
        Action   = [
          "codebuild:*",
          "codestar-connections:*"
        ]
        Resource = "*"
      },
      # 4. صلاحيات ضرورية للخدمات المرتبطة (EC2, ASG, RDS, CloudFormation)
      {
        Effect   = "Allow"
        Action   = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "sns:*",
          "cloudformation:*",
          "rds:*"
        ]
        Resource = "*"
      },
      # 5. صلاحية تمرير أي رول (PassRole) لضمان عدم توقف Beanstalk
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*"
      }
    ]
  })
}