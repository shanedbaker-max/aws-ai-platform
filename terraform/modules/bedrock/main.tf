data "aws_caller_identity" "current" {}

# ================================================================
# IAM — Bedrock KB Service Role
# Assumed BY Bedrock to read S3 and invoke Titan Embeddings.
#
# CONSOLE DEPENDENCY: After first apply, copy the
# bedrock_kb_role_arn output and use it when creating the KB
# in console. Do NOT let console create its own role.
# ================================================================

data "aws_iam_policy_document" "bedrock_kb_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "bedrock_kb" {
  name               = "${var.project}-${var.environment}-role-bedrock-kb"
  assume_role_policy = data.aws_iam_policy_document.bedrock_kb_assume.json

  tags = {
    project    = var.project
    env        = var.environment
    managed_by = "terraform"
  }
}

data "aws_iam_policy_document" "bedrock_kb_permissions" {
  statement {
    sid    = "S3ReadKBSource"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.kb_source_bucket_arn,
      "${var.kb_source_bucket_arn}/*"
    ]
  }

  statement {
    sid    = "TitanEmbeddingsInvoke"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-v2:0"
    ]
  }
}

resource "aws_iam_role_policy" "bedrock_kb" {
  name   = "${var.project}-${var.environment}-policy-bedrock-kb"
  role   = aws_iam_role.bedrock_kb.id
  policy = data.aws_iam_policy_document.bedrock_kb_permissions.json
}

# ================================================================
# IAM — KB Sync permissions attached to existing Lambda role
# Adds ingestion job permissions to lambda_orchestrator role.
# ================================================================

data "aws_iam_policy_document" "kb_sync_permissions" {
  statement {
    sid    = "BedrockKBIngestion"
    effect = "Allow"
    actions = [
      "bedrock:StartIngestionJob",
      "bedrock:GetIngestionJob",
      "bedrock:ListIngestionJobs"
    ]
    # Scoped to specific KB once kb_id is set, wildcard until then
    resources = var.kb_id != "" ? [
      "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:knowledge-base/${var.kb_id}"
    ] : ["arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"]
  }

  statement {
    sid    = "S3ReadForSync"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.kb_source_bucket_arn,
      "${var.kb_source_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "kb_sync_lambda" {
  name   = "${var.project}-${var.environment}-policy-kb-sync"
  role   = var.lambda_orchestrator_role_name
  policy = data.aws_iam_policy_document.kb_sync_permissions.json
}

# ================================================================
# Lambda — KB Sync function
# Triggered by S3 uploads. Starts Bedrock ingestion job.
#
# CONSOLE DEPENDENCY: KB_ID env var is empty until KB is created
# in console. Lambda exits cleanly with a warning if not set.
# ================================================================

data "archive_file" "kb_sync_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/kb_sync/handler.py"
  output_path = "${path.module}/../../../lambda/kb_sync/kb_sync.zip"
}

resource "aws_lambda_function" "kb_sync" {
  function_name    = "${var.project}-${var.environment}-kb-sync"
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.lambda_orchestrator_role_name}"
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.kb_sync_zip.output_path
  source_code_hash = data.archive_file.kb_sync_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      KB_ID             = var.kb_id
      KB_DATA_SOURCE_ID = var.kb_data_source_id
      LOG_LEVEL         = "INFO"
    }
  }

  tags = {
    project    = var.project
    env        = var.environment
    managed_by = "terraform"
  }
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3InvokeKBSync"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kb_sync.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.kb_source_bucket_arn
}

resource "aws_s3_bucket_notification" "kb_source_trigger" {
  bucket = var.kb_source_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.kb_sync.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

# ================================================================
# Bedrock Data Source
# CONSOLE DEPENDENCY: Skipped (count=0) until kb_id is set.
# After console KB creation:
#   1. Set kb_id in terraform.tfvars
#   2. terraform apply — this resource gets created
#   3. Copy kb_data_source_id from outputs into tfvars
# ================================================================

resource "aws_bedrockagent_data_source" "kb_s3" {
  count = var.kb_id != "" ? 1 : 0

  knowledge_base_id = var.kb_id
  name              = "${var.project}-${var.environment}-kb-datasource-s3"

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.kb_source_bucket_arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens         = 512
        overlap_percentage = 20
      }
    }
  }
}
