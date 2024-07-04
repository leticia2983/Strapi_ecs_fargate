resource "aws_ecs_cluster" "ecs" {
  name = "app_cluster"
}

resource "aws_ecs_service" "service" {
  name = "app_service"
  cluster                = aws_ecs_cluster.ecs.arn
  launch_type            = "FARGATE"
  enable_execute_command = true

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  task_definition                    = aws_ecs_task_definition.td.arn

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = [aws_subnet.sn1.id, aws_subnet.sn2.id, aws_subnet.sn3.id]
  }
}

resource "aws_ecs_task_definition" "td" {
  container_definitions = jsonencode([
    {
      name         = "app"
      image        = "533266978173.dkr.ecr.us-west-1.amazonaws.com/app_repo"
      cpu          = 256
      memory       = 512
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  family                   = "app"
  requires_compatibilities = ["FARGATE"]

  cpu                = "256"
  memory             = "512"
  network_mode       = "awsvpc"
  task_role_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  execution_role_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

  container_definitions = jsonencode([
    {
      name      = "strapi-db"
      image     = "strapi:latest"
      essential = true
      environment = [
        {
          name  = "mysql"
          value = "strapi"
        },
        {
          name  = "strapi_user"
          value = "strapi_user"
        },
        {
          name  = "mysql_PASSWORD"
          value = "password"
        }
      ],
      portMappings = [
        {
          containerPort = 5432
          protocol      = "tcp"
        }
      ]
    },
    {
      name      = "strapi-server"
      image     = "leticia888444/strapi_docker_final:1.0"
      essential = true
      dependsOn = [{
        containerName = "strapi"
        condition     = "START"
      }],
      environment = [
        {
          name  = "DATABASE_CLIENT"
          value = "mysql"
        },
        {
          name  = "DATABASE_HOST"
          value = "localhost"
        },
        {
          name  = "DATABASE_PORT"
          value = "5432"
        },
        {
          name  = "DATABASE_NAME"
          value = "strapi"
        },
        {
          name  = "DATABASE_USERNAME"
          value = "strapi_user"
        },
        {
          name  = "DATABASE_PASSWORD"
          value = "password"
        }
      ],
      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.sn1.id]
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = true
  }

}
