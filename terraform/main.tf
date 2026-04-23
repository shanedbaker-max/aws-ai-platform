terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "aiplatform-terraform-state-481005548335"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aiplatform-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project    = "aiplatform"
      env        = var.environment
      managed_by = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

# IAM module
module "iam" {
  source = "./modules/iam"
  
  project     = var.project
  environment = var.environment
}

# DynamoDB module
module "dynamodb" {
  source = "./modules/dynamodb"
  
  project     = var.project
  environment = var.environment
}

# Lambda module
module "lambda" {
  source = "./modules/lambda"
  
  project                       = var.project
  environment                   = var.environment
  lambda_orchestrator_role_arn  = module.iam.lambda_orchestrator_role_arn
  events_table_name            = module.dynamodb.events_table_name
  sessions_table_name          = module.dynamodb.sessions_table_name
  dashboard_table_name         = module.dynamodb.dashboard_table_name
}

# API Gateway module
module "api_gateway" {
  source = "./modules/api_gateway"
  
  project                             = var.project
  environment                         = var.environment
  lambda_orchestrator_arn             = module.lambda.orchestrator_function_arn
  lambda_orchestrator_function_name   = module.lambda.orchestrator_function_name
}
module "s3" {
  source  = "./modules/s3"
  project = var.project
  env = var.environment
}