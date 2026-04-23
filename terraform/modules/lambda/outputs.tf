output "orchestrator_function_arn" {
  description = "ARN of the orchestrator Lambda function"
  value       = aws_lambda_function.orchestrator.arn
}

output "orchestrator_function_name" {
  description = "Name of the orchestrator Lambda function"
  value       = aws_lambda_function.orchestrator.function_name
}

output "orchestrator_invoke_arn" {
  description = "Invoke ARN of the orchestrator Lambda function"
  value       = aws_lambda_function.orchestrator.invoke_arn
}
