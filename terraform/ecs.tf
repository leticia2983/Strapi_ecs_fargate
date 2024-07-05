resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-let5"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "leticia888444/strapi_docker_final:1.0"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
    }
  ])
}
resource "aws_ecs_service" "strapi" {
  name            = "strapi-let5-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets         = var.subnet_ids
    assign_public_ip = true
    security_groups = [aws_security_group.strapi_sg.id]
  }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.strapi_tg.arn
#     container_name   = "strapi"
#     container_port   = 1337
#   }
#
#   depends_on = [aws_lb_listener.http_listener]
# }


#   container_definitions = jsonencode([
#     {
#       name      = "strapi-db",
#       image     = "mysql:5.7",
#       essential = true,
#       environment = [
#         {
#           name  = "MYSQL_DATABASE",
#           value = "strapi"
#         },
#         {
#           name  = "MYSQL_USER",
#           value = "strapi_user"
#         },
#         {
#           name  = "MYSQL_PASSWORD",
#           value = "password"
#         }
#       ],
#       portMappings = [
#         {
#           containerPort = 3306,
#           protocol      = "tcp"
#         }
#       ]
#     },
#     {
#       name      = "strapi-server",
#       image     = "533266978173.dkr.ecr.us-west-1.amazonaws.com/app_repo:latest",
#       essential = true,
#       dependsOn = [{
#         containerName = "strapi-db",
#         condition     = "START"
#       }],
#       environment = [
#         {
#           name  = "DATABASE_CLIENT",
#           value = "mysql"
#         },
#         {
#           name  = "DATABASE_HOST",
#           value = "localhost"
#         },
#         {
#           name  = "DATABASE_PORT",
#           value = "3306"
#         },
#         {
#           name  = "DATABASE_NAME",
#           value = "strapi"
#         },
#         {
#           name  = "DATABASE_USERNAME",
#           value = "strapi_user"
#         },
#         {
#           name  = "DATABASE_PASSWORD",
#           value = "password"
#         }
#       ],
#       portMappings = [
#         {
#           containerPort = 1337,
#           protocol      = "tcp"
#         }
#       ]
#     }
#   ])
# }


