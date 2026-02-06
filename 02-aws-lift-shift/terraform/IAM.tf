# 1. Define an IAM policy document for the EC2 instance to assume the role
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

# 2. Create the IAM role using the assume role policy document
resource "aws_iam_role" "ec2_s3_role" {
  name               = "ec2-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# 3. Define an IAM policy document for S3 access (e.g., GetObject and ListBucket)
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.Artifact-Bucket.arn,
      "${aws_s3_bucket.Artifact-Bucket.arn}/*", # Policy requires both bucket and object ARNs
    ]
  }
}

# 4. Create the IAM policy using the S3 access policy document
resource "aws_iam_policy" "s3_access_policy" {
  name   = "s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

# 5. Attach the S3 access policy to the EC2 role
resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# 6. Create an Instance Profile (required to attach the role to the EC2 instance)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

