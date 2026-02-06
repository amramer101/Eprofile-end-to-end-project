# 1. The Entry Point (Browser URL)
output "website_url" {
  description = "Access the EProfile Application here"
  value       = "http://${module.ec2_instance_nginx.public_ip}"
}

# 2. Server Public IPs (For SSH Access)
output "ssh_commands" {
  description = "Copy these commands to SSH into servers"
  value = {
    nginx  = "ssh -i ec2-eprofile-key ubuntu@${module.ec2_instance_nginx.public_ip}"
    tomcat = "ssh -i ec2-eprofile-key ubuntu@${module.ec2_instance_tomcat.public_ip}"
    mysql  = "ssh -i ec2-eprofile-key ubuntu@${module.ec2_instance_mysql.public_ip}"
  }
}

# 3. Internal IPs (For Debugging / Config)
output "internal_ips" {
  description = "Private IPs for internal communication"
  value = {
    db_private  = module.ec2_instance_mysql.private_ip
    mc_private  = module.ec2_instance_memcache.private_ip
    rmq_private = module.ec2_instance_rabbitmq.private_ip
  }
}