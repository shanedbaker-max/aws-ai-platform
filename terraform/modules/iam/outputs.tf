output "lambda_orchestrator_role_arn" {
  description = "ARN of the Lambda orchestrator execution role"
  value       = aws_iam_role.lambda_orchestrator.arn
}

output "lambda_action_groups_role_arn" {
  description = "ARN of the Lambda action groups execution role"
  value       = aws_iam_role.lambda_action_groups.arn
}
output "lambda_orchestrator_role_name" {
  description = "Name of the Lambda orchestrator execution role"
  value       = aws_iam_role.lambda_orchestrator.name
}
