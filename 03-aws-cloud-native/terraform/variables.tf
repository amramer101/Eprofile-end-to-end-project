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

variable "piv_key_path" {
  default = "bean-stack-key"
}

## DataBase Services Variables

variable "db_name" {
  default = "mydb"
}

variable "db_user_name" {
  default = "admin"
}

variable "db_password" {
  default = "admin123"
}

## RabbitMQ Variables

variable "rmq_user" {
  default = "rabbit"
}

variable "rmq_password" {
  default = "Gr33n@pple123456"
}