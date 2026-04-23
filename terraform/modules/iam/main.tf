# Lambda execution role for orchestrator
resource "aws_iam_role" "lambda_orchestrator" {
  name = "${var.project}-${var.environment}-lambda-orchestrator"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda execution role for action groups (Bedrock Agent functions)
resource "aws_iam_role" "lambda_action_groups" {
  name = "${var.project}-${var.environment}-lambda-action-groups"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Basic Lambda execution policy attachment
resource "aws_iam_role_policy_attachment" "lambda_orchestrator_basic" {
  role       = aws_iam_role.lambda_orchestrator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_action_groups_basic" {
  role       = aws_iam_role.lambda_action_groups.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB policy for Lambda functions
resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${var.project}-${var.environment}-lambda-dynamodb"
  description = "DynamoDB access for Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "arn:aws:dynamodb:*:*:table/${var.project}-${var.environment}-*"
        ]
      }
    ]
  })
}

# Bedrock policy for Lambda functions
resource "aws_iam_policy" "lambda_bedrock" {
  name        = "${var.project}-${var.environment}-lambda-bedrock"
  description = "Bedrock access for Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policies to orchestrator role
resource "aws_iam_role_policy_attachment" "lambda_orchestrator_dynamodb" {
  role       = aws_iam_role.lambda_orchestrator.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "lambda_orchestrator_bedrock" {
  role       = aws_iam_role.lambda_orchestrator.name
  policy_arn = aws_iam_policy.lambda_bedrock.arn
}

# Attach policies to action groups role
resource "aws_iam_role_policy_attachment" "lambda_action_groups_dynamodb" {
  role       = aws_iam_role.lambda_action_groups.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "lambda_action_groups_bedrock" {
  role       = aws_iam_role.lambda_action_groups.name
  policy_arn = aws_iam_policy.lambda_bedrock.arn
}
