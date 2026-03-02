
#  CodePipeline
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

  # Stage 2: Security Scan
  stage {
    name = "Build"

    action {
      name             = "SecurityScan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["security_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.vprofile_security_scan.name
      }
    }
  }

  # Stage 3: Build
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

  # Stage 4: Deploy
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