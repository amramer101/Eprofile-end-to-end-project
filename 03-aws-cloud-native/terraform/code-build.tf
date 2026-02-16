# 1. S3 Bucket for Artifacts
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "vprofile-cicd-artifacts-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. CodeBuild Project
resource "aws_codebuild_project" "vprofile_build" {
  name         = "vprofile-build-job"
  description  = "Builds the Java vProfile application"
  service_role = aws_iam_role.codebuild_role.arn

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
    buildspec = "03-aws-cloud-native/buildspec.yml"
  }
}

# 3. CodeStar Connection 
resource "aws_codestarconnections_connection" "github_connection" {
  name          = "vprofile-github-conn"
  provider_type = "GitHub"
}

# 4. CodePipeline
resource "aws_codepipeline" "vprofile_pipeline" {
  name          = "vprofile-pipeline"
  role_arn      = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = ["main"]
        }
        file_paths {
          includes = ["src/.*"] ## only trigger pipeline if files in this path are changed
        }
      }
    }
  }

  # Stage 1: Source
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_connection.arn ## replace with your actual connection ARN
        FullRepositoryId = "amramer101/Strata-Ops"                                  ## your GitHub username/repo
        BranchName       = "main"
        DetectChanges    = "false"
      }
    }
  }

  # Stage 2: Build
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.vprofile_build.name
      }
    }
  }

  # Stage 3: Deploy
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.Eprofile_bean_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.elbeanstalk_env.name
      }
    }
  }
}