variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "aiplatform"
}
variable "kb_id" {
  type        = string
  description = "Bedrock KB ID — set after console KB creation"
  default     = ""
}

variable "kb_data_source_id" {
  type        = string
  description = "Bedrock data source ID — set after first apply with kb_id"
  default     = ""
}