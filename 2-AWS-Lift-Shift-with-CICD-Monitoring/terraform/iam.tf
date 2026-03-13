data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_ssm_role" {
  name               = "ec2-ssm-access-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ssm_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/strata-ops/*"
    ]
  }
}

resource "aws_iam_policy" "ssm_access_policy" {
  name   = "strata-ops-ssm-policy"
  policy = data.aws_iam_policy_document.ssm_access_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "strata-ops-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}