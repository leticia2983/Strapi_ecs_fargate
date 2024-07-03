resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster"
}


resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
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
