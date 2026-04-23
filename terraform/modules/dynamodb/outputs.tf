output "events_table_name" {
  description = "Name of the events DynamoDB table"
  value       = aws_dynamodb_table.events.name
}

output "events_table_arn" {
  description = "ARN of the events DynamoDB table"
  value       = aws_dynamodb_table.events.arn
}

output "sessions_table_name" {
  description = "Name of the sessions DynamoDB table"
  value       = aws_dynamodb_table.sessions.name
}

output "sessions_table_arn" {
  description = "ARN of the sessions DynamoDB table"
  value       = aws_dynamodb_table.sessions.arn
}

output "dashboard_table_name" {
  description = "Name of the dashboard DynamoDB table"
  value       = aws_dynamodb_table.dashboard.name
}

output "dashboard_table_arn" {
  description = "ARN of the dashboard DynamoDB table"
  value       = aws_dynamodb_table.dashboard.arn
}
