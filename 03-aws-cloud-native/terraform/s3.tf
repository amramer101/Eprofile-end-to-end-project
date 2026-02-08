resource "aws_s3_bucket" "Artifact-Bucket" {
  bucket = var.S3_Bucket_Name

  tags = {
    Name        = "Atifact-Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "artifact" {
  bucket = aws_s3_bucket.Artifact-Bucket.id
  key    = "vprofile-v2.war"
  source = "../target/vprofile-v2.war"
  etag   = filemd5("../target/vprofile-v2.war")
}