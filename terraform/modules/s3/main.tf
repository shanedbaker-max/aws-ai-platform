resource "aws_s3_bucket" "kb_source" {
  bucket = "${var.project}-${var.env}-kb-source"

  tags = {
    project    = var.project
    env        = var.env
    managed_by = "terraform"
    purpose    = "bedrock-kb-source"
  }
}

resource "aws_s3_bucket_versioning" "kb_source" {
  bucket = aws_s3_bucket.kb_source.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kb_source" {
  bucket = aws_s3_bucket.kb_source.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "kb_source" {
  bucket = aws_s3_bucket.kb_source.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


