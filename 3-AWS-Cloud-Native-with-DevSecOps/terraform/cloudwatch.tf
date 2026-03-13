# (CloudWatch Alarm)
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "vprofile-High-CPU-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This alarm fires if Beanstalk CPU exceeds 80%"

  alarm_actions = [aws_sns_topic.beanstalk_alerts.arn]

  dimensions = {
    AutoScalingGroupName = aws_elastic_beanstalk_environment.elbeanstalk_env.autoscaling_groups[0]
  }
}