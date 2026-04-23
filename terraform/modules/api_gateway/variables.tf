variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_orchestrator_arn" {
  description = "ARN of the Lambda orchestrator function"
  type        = string
}

variable "lambda_orchestrator_function_name" {
  description = "Name of the Lambda orchestrator function"
  type        = string
}
