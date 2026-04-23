variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_orchestrator_role_arn" {
  description = "ARN of the Lambda orchestrator execution role"
  type        = string
}

variable "events_table_name" {
  description = "Name of the events DynamoDB table"
  type        = string
}

variable "sessions_table_name" {
  description = "Name of the sessions DynamoDB table"
  type        = string
}

variable "dashboard_table_name" {
  description = "Name of the dashboard DynamoDB table"
  type        = string
}
