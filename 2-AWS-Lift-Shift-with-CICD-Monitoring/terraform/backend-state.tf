terraform {
  backend "s3" {
    bucket = "s3-terraform-2026"
    key    = "s3-terraform-2026/terraform"
    region = "eu-central-1"
  }
}
