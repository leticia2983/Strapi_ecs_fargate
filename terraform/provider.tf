terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = var.region
   assume_role {
      role_arn = "arn:aws:iam::058264299421:role/terraform"
    }
  }


