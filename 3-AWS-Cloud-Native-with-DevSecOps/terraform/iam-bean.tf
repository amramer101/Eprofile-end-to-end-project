# 1. Service Role (aws-elasticbeanstalk-service-role)
resource "aws_iam_role" "beanstalk_service" {
  name = "eprofile-beanstalk-service-role-auto"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "elasticbeanstalk.amazonaws.com" }
      Condition = { StringLike = { "sts:ExternalId" = "elasticbeanstalk" } }
    }]
  })
}

# Attachments for Service Role 
resource "aws_iam_role_policy_attachment" "service_enhanced_health" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "service_managed_updates" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

# 2. EC2 Instance Role (beanstack-role)
resource "aws_iam_role" "beanstalk_ec2" {
  name = "eprofile-beanstalk-ec2-role-auto"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Attachments for EC2 Role 

# 1. AdministratorAccess-AWSElasticBeanstalk
resource "aws_iam_role_policy_attachment" "ec2_admin" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}

# 2. AWSElasticBeanstalkCustomPlatformforEC2Role
resource "aws_iam_role_policy_attachment" "ec2_custom_platform" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkCustomPlatformforEC2Role"
}

# 3. AWSElasticBeanstalkRoleSNS 
resource "aws_iam_role_policy_attachment" "ec2_sns" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleSNS"
}

# 4. AWSElasticBeanstalkWebTier
resource "aws_iam_role_policy_attachment" "ec2_web_tier" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

# 3. Instance Profile (The Wrapper)
resource "aws_iam_instance_profile" "beanstalk_ec2_profile" {
  name = "eprofile-beanstalk-ec2-profile-auto"
  role = aws_iam_role.beanstalk_ec2.name
}