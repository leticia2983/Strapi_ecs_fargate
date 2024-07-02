provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "let-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "let-subnet" {
  count                   = 1
  vpc_id                  = aws_vpc.let-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.let-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "strapi" {

  name = "strapi-let"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
      scan_on_push = true
    }
}

resource "aws_ecs_cluster" "main" {
  name = "strapi-cluster"
}

resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${aws_ecr_repository.strapi.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
      environment = [
        {
          name  = "DATABASE_CLIENT"
          value = "mysql"
        },
        {
          name  = "DATABASE_HOST"
          value = "your-database-endpoint"
        },
        {
          name  = "DATABASE_PORT"
          value = "3306"
        },
        {
          name  = "DATABASE_NAME"
          value = "strapi"
        },
        {
          name  = "DATABASE_USERNAME"
          value = "strapi"
        },
        {
          name  = "DATABASE_PASSWORD"
          value = "strapi"
        },
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "strapi" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.let-vpc.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnet        = aws_subnet.let-subnet.id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}

resource "aws_route53_record" "strapi" {
  zone_id = "Z06607023RJWXGXD2ZL6M"
  name    = "leticia.contentecho.in"
  type    = "A"
  ttl     = 300
  records = [aws_eip.strapi.public_ip]
}

resource "aws_eip" "strapi" {
  vpc = true
}
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

