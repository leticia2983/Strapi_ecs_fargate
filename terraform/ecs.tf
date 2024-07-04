resource "aws_ecs_cluster" "ecs" {
  name = var.cluster_name
}

resource "aws_ecs_service" "service" {
  name                    = var.service_name
  cluster                 = aws_ecs_cluster.ecs.arn
  launch_type             = "FARGATE"
  enable_execute_command  = true

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  task_definition                    = aws_ecs_task_definition.td.arn

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.sg.id]
    subnets          = [aws_subnet.sn1.id]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "td" {
  family               = var.aws_ecs_task_definition
  cpu                  = "256"
  memory               = "512"
  network_mode         = "awsvpc"
  task_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn   = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "strapi-db",
      image     = "mysql:5.7",
      essential = true,
      environment = [
        {
          name  = "MYSQL_DATABASE",
          value = "strapi"
        },
        {
          name  = "MYSQL_USER",
          value = "strapi_user"
        },
        {
          name  = "MYSQL_PASSWORD",
          value = "password"
        }
      ],
      portMappings = [
        {
          containerPort = 3306,
          protocol      = "tcp"
        }
      ]
    },
    {
      name      = "strapi-server",
      image     = "533266978173.dkr.ecr.us-west-1.amazonaws.com/app_repo:latest",
      essential = true,
      dependsOn = [{
        containerName = "strapi-db",
        condition     = "START"
      }],
      environment = [
        {
          name  = "DATABASE_CLIENT",
          value = "mysql"
        },
        {
          name  = "DATABASE_HOST",
          value = "localhost"
        },
        {
          name  = "DATABASE_PORT",
          value = "3306"
        },
        {
          name  = "DATABASE_NAME",
          value = "strapi"
        },
        {
          name  = "DATABASE_USERNAME",
          value = "strapi_user"
        },
        {
          name  = "DATABASE_PASSWORD",
          value = "password"
        }
      ],
      portMappings = [
        {
          containerPort = 1337,
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "strapi_service" {
  name            = var.strapi_service
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.sn1.id]
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = true
  }
}
