variable "cluster_name" {
  default = "leticia_app_cluster"
}

variable "service_name" {
  default = "leticia_app_service"
}

variable "ecs_task_execution_role" {
  default = "ecsTaskExecutionRoleStrapi-let30"
}

variable "aws_ecs_task_definition" {
  default = "strapi-task"
}

variable "strapi_service" {
  default = "strapi-service"
}

variable "security_group" {
  default = "sg"
}
variable "region" {
  default = "us-west-1"
}

