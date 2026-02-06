resource "aws_s3_bucket" "Atifact-Bucket" {
  bucket = "S3-terraform-2026-java-artifacts1598"

  tags = {
    Name        = "Atifact-Bucket"
    Environment = "Dev"
  }
}