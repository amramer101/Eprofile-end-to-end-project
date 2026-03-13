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


## 4. Service URLs (For Accessing Services) C/CD Pipeline, Monitoring, etc.

output "nexus_ip" {
  description = "The public IP of the nexus host"
  value       = "http://${module.ec2_instance_nexus.public_ip}:8081"
}

output "jenkins_ip" {
  description = "The public IP of the jenkins host"
  value       = "http://${module.ec2_instance_Jenkins.public_ip}:8080"
}


output "sonar_ip" {
  description = "The public IP of the Sonar host"
  value       = "http://${module.ec2_instance_sonarqube.public_ip}:9000"
}


output "prometheus_ip" {
  description = "The public IP of the Prometheus host"
  value       = "http://${module.ec2_instance_prometheus.public_ip}:9090"
}

output "grafana_ip" {
  description = "The public IP of the Grafana host"
  value       = "http://${module.ec2_instance_grafana.public_ip}:3000"

}