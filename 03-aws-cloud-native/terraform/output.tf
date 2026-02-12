
## Outputs for the created resources

## Beanstalk Environment URL
output "beanstalk_env_url" {
  value = aws_elastic_beanstalk_environment.elbeanstalk_env.endpoint_url
}


### RDS Endpoint

output "rds_endpoint" {
  value = aws_db_instance.RDS.address
}


## ElastiCache Endpoint
output "elasticache_endpoint" {
  value = aws_elasticache_cluster.ElastiCache.configuration_endpoint
}

## RabbitMQ Endpoint
output "mq_endpoint" {
  description = "The endpoint for RabbitMQ Broker"
  value       = aws_mq_broker.RabbitMQ.instances.0.endpoints
}

## Bastion Host Public IP
output "bastion_ip" {
  description = "The public IP of the Bastion host"
  value       = aws_instance.bastion[0].public_ip
}