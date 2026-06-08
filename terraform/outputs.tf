output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

# API Gateway outputs
output "api_invoke_url" {
  description = "API Gateway invoke URL"
  value       = module.api_gateway.invoke_url
}

# Lambda outputs  
output "lambda_orchestrator_arn" {
  description = "ARN of the orchestrator Lambda function"
  value       = module.lambda.orchestrator_function_arn
}
