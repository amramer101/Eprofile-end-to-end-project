variable "AWS_Region" {
  default = "eu-central-1"
}

## VPC Variables

variable "VPC_Name" {
  default = "Eprofile-VPC-Docker"
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

## Key Variables

variable "pub_key_path" {
  default = "docker-githubActions.pub"
}

variable "priv_key_path" {
  default = "docker-githubActions"
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
