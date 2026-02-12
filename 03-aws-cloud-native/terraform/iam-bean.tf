# -----------------------------------------------------------
# 1. Service Role (For Elastic Beanstalk Service itself)
# -----------------------------------------------------------
resource "aws_iam_role" "beanstalk_service" {
  name = "vprofile-beanstalk-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "elasticbeanstalk.amazonaws.com"
      }
      Condition = {
        StringLike = {
          "sts:ExternalId" = "elasticbeanstalk"
        }
      }
    }]
  })
}

# Attach "Enhanced Health" Policy
resource "aws_iam_role_policy_attachment" "beanstalk_service_enhanced_health" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

# Attach "Managed Updates" Policy
resource "aws_iam_role_policy_attachment" "beanstalk_service_managed" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkManagedUpdates"
}

# -----------------------------------------------------------
# 2. EC2 Instance Role (For the Tomcat Instances)
# -----------------------------------------------------------
resource "aws_iam_role" "beanstalk_ec2" {
  name = "vprofile-beanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 1. WebTier
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_web" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

# 2. WorkerTier
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_worker" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

# 3. AdministratorAccess-AWSElasticBeanstalk
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_admin" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}

# 4. AWSElasticBeanstalkRoleSNS
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_sns" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkRoleSNS"
}


# -----------------------------------------------------------
# 3. Instance Profile (The Wrapper)
# -----------------------------------------------------------
resource "aws_iam_instance_profile" "beanstalk_ec2_profile" {
  name = "vprofile-beanstalk-ec2-profile"
  role = aws_iam_role.beanstalk_ec2.name
}