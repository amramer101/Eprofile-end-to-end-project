# (SNS Topic)
resource "aws_sns_topic" "beanstalk_alerts" {
  name = "vprofile-beanstalk-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.beanstalk_alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}