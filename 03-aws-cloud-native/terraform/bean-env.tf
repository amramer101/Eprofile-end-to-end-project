
resource "aws_elastic_beanstalk_environment" "elbeanstalk_env" {
  name                = "elbeanstalkenv"
  application         = aws_elastic_beanstalk_application.Eprofile_bean_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v5.9.3 running Tomcat 10 Corretto 21"
  cname_prefix        = "eprofileapp254698"


  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = data.aws_iam_instance_profile.existing_ec2_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    # الصح: نستخدم الـ Service Role (للخدمة)
    value = data.aws_iam_role.existing_service_role.name
  }

  # --- باقي الإعدادات (سليمة) ---

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "gp3"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = true
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]])
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.EC2_Key_Pair.key_name
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "2" # قللتها لـ 2 عشان الـ Free Tier
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.Tomcat-SG.id
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.Load-Balancer-SG.id
  }

  depends_on = [aws_security_group.Load-Balancer-SG, aws_security_group.Tomcat-SG]
}