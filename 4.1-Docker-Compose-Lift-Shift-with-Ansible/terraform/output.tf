
## Outputs for the created resources

## Bastion Docker Public IP
output "Docker_ip" {
  description = "The public IP of the Docker instance"
  value       = module.ec2_instance_docker[0].public_ip
}