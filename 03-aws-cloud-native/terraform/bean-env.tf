
resource "aws_elastic_beanstalk_environment" "elbeanstalk_env" {
  name                = "elbeanstalkenv"
  application         = aws_elastic_beanstalk_application.Eprofile_bean_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v5.9.3 running Tomcat 10 Corretto 21"
  cname_prefix        = "eprofileapp254698"


  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_role.beanstalk_ec2.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value = aws_iam_role.beanstalk_service.name
  }

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
    value     = "2" 
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


    setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_HOSTNAME"
    value     = aws_db_instance.RDS.address
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_USERNAME"
    value     = var.db_user_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_PASSWORD"
    value     = var.db_password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MEMCACHED_HOSTNAME"
    value     = aws_elasticache_cluster.ElastiCache.cluster_address
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RABBITMQ_HOSTNAME"
    # معادلة عشان تجيب الدومين بس من غير بروتوكول
    value     = split("/", split("@", aws_mq_broker.RabbitMQ.instances[0].endpoints[0])[0])[2]
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RABBITMQ_USERNAME"
    value     = var.rmq_user 
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RABBITMQ_PASSWORD"
    value     = var.rmq_password 
  }

  depends_on = [aws_security_group.Load-Balancer-SG, aws_security_group.Tomcat-SG, aws_iam_role.beanstalk_service, aws_iam_role.beanstalk_ec2]
}