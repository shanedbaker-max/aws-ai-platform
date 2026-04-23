# Create ZIP file for Lambda deployment
data "archive_file" "orchestrator_zip" {
  type        = "zip"
  source_file = "${path.root}/../lambda/orchestrator/handler.py"
  output_path = "${path.root}/../lambda/orchestrator/function.zip"
}

# Lambda function
resource "aws_lambda_function" "orchestrator" {
  filename         = data.archive_file.orchestrator_zip.output_path
  function_name    = "${var.project}-${var.environment}-orchestrator"
  role            = var.lambda_orchestrator_role_arn
  handler         = "handler.lambda_handler"
  source_code_hash = data.archive_file.orchestrator_zip.output_base64sha256
  runtime         = "python3.12"
  timeout         = 30

  environment {
    variables = {
      ENVIRONMENT      = var.environment
      EVENTS_TABLE     = var.events_table_name
      SESSIONS_TABLE   = var.sessions_table_name
      DASHBOARD_TABLE  = var.dashboard_table_name
    }
  }

  tags = {
    Name = "${var.project}-${var.environment}-orchestrator"
  }
}
