variable "AWS_Region" {
  default = "eu-central-1"
}

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

variable "AWS_Zone-a" {
  default = "eu-central-1a"
}

variable "AWS_Zone-b" {
  default = "eu-central-1b"
}

variable "AWS_Zone-c" {
  default = "eu-central-1c"
}

variable "S3_Bucket_Name" {
  default = "s3-terraform-2026-java-artifacts1598"

}

variable "Pub_Key_Path" {
  default = "bean-stack-key.pub"
}

variable "db_name" {
  default = "mydb"
}

variable "db_user_name" {
  default = "admin"
}

variable "db_password" {
  default = "admin123"
}

variable "rmq_user" {
  default = "rabbit"
}

variable "rmq_password" {
  default = "Gr33n@pple123456"
}