variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "kb_source_bucket_arn" {
  type        = string
  description = "From s3 module output: kb_source_bucket_arn"
}

variable "kb_source_bucket_name" {
  type        = string
  description = "From s3 module output: kb_source_bucket_name"
}

variable "lambda_orchestrator_role_name" {
  type        = string
  description = "From iam module output: lambda_orchestrator_role_name"
}

variable "kb_id" {
  type        = string
  description = "CONSOLE DEPENDENCY: empty until KB created in console"
  default     = ""
}

variable "kb_data_source_id" {
  type        = string
  description = "Set after first apply with kb_id"
  default     = ""
}
