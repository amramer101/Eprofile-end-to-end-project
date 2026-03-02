# 1. S3 Bucket for Artifacts
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "vprofile-cicd-artifacts-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. CodeBuild Project for building the application
resource "aws_codebuild_project" "vprofile_build" {
  name         = "vprofile-build-job"
  description  = "Builds the Java vProfile application"
  service_role = aws_iam_role.codebuild_build_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "03-aws-cloud-native/buildspec-build.yml"
  }
}

## ---------------------------------------------------------------------

# 3. CodeStar Connection 
resource "aws_codestarconnections_connection" "github_connection" {
  name          = "vprofile-github-conn"
  provider_type = "GitHub"
}


## ---------------------------------------------------------------------

## 4. Codebuild Project for Security Scanning (SonarQube)


resource "aws_codebuild_project" "vprofile_security_scan" {
  name         = "vprofile-security-scan-job"
  description  = "Scans the Java vProfile application for security issues"
  service_role = aws_iam_role.codebuild_security_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "03-aws-cloud-native/buildspec-sec.yml"
  }
}




