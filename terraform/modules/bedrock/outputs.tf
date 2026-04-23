output "bedrock_kb_role_arn" {
  value       = aws_iam_role.bedrock_kb.arn
  description = "USE THIS ARN when creating the KB in console"
}

output "bedrock_kb_role_name" {
  value = aws_iam_role.bedrock_kb.name
}

output "kb_sync_lambda_name" {
  value = aws_lambda_function.kb_sync.function_name
}

output "kb_sync_lambda_arn" {
  value = aws_lambda_function.kb_sync.arn
}

output "kb_data_source_id" {
  value       = var.kb_id != "" ? aws_bedrockagent_data_source.kb_s3[0].data_source_id : "not-yet-created"
  description = "Set kb_data_source_id in tfvars after this outputs a real ID"
}
