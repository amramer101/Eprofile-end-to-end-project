
## Tomcat cluster ----------------------------------------
resource "aws_ecs_cluster" "tomcat_cluster" {
  name = "strata-tomcat-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

## (Task Definition) - Fargate  ---------------------------

resource "aws_ecs_task_definition" "tomcat_definition" {
  family                   = "eprofile-tomcat-task"
  requires_compatibilities = ["FARGATE"] # ٍServerless
  network_mode             = "awsvpc"   
  cpu                      = 512       
  memory                   = 1024
  
  # Role for SSM
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn 

  container_definitions = jsonencode([
    {
      name      = "vproapp"
      image     = "amrmamer/vprofileapp:latest"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

## (ECS Service) --------------------------------------------

resource "aws_ecs_service" "tomcat_service" {
  name            = "eprofile-tomcat-svc"
  cluster         = aws_ecs_cluster.tomcat_cluster.id
  task_definition = aws_ecs_task_definition.tomcat_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ECS-SG.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["tomcat_tg"].arn
    container_name   = "vproapp"
    container_port   = 8080
  }
}