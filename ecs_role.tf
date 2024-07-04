resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role-strapi-let1"

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
   role = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}
