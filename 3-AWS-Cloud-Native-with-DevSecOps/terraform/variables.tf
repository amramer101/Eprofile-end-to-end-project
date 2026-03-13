variable "AWS_Region" {
  default = "eu-central-1"
}

## VPC Variables

variable "VPC_Name" {
  default = "Eprofile-VPC"
}

variable "VPC_CIDR" {
  default = "10.0.0.0/16"
}

variable "Public_Subnet_CIDR" {
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "Private_Subnet_CIDR" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

## Availability Zones

variable "AWS_Zone-a" {
  default = "eu-central-1a"
}

variable "AWS_Zone-b" {
  default = "eu-central-1b"
}

variable "AWS_Zone-c" {
  default = "eu-central-1c"
}

## S3 Variables

variable "S3_Bucket_Name" {
  default = "s3-terraform-2026-java-artifacts1598"

}


## Key Variables

variable "pub_key_path" {
  default = "bean-stack-key.pub"
}

variable "priv_key_path" {
  default = "bean-stack-key"
}

## DataBase Services Variables

variable "db_name" {
  default = "accounts"
}

variable "db_user_name" {
  default = "admin"
}


## RabbitMQ Variables

variable "rmq_user" {
  default = "rabbit"
}


## Bastion Host Variables

variable "bastion_host_username" {
  default = "ubuntu"
}

## SNS Variables Email

variable "sns_email" {
  default = "amrmedhatamer100@gmail.com"
}


## ElastiBeansalk Variables

variable "beanstalk_cname" {
  default = "eprofileapp254698"
}

## SonarCloud Variables

variable "sonar_token" {
  description = "SonarCloud Authentication Token"
  type        = string
  sensitive   = true
}

variable "sonar_organization" {
  description = "SonarCloud Organization Name"
  type        = string
  default     = "amramer101"
}

variable "sonar_project_key" {
  description = "SonarCloud Project Key"
  type        = string
  default     = "amramer101_Strata-Ops"
}