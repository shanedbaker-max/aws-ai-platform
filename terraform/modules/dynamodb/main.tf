# Events table - stores all platform events for dashboards and audit
resource "aws_dynamodb_table" "events" {
  name           = "${var.project}-${var.environment}-events"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "event_id"
  range_key      = "timestamp"

  attribute {
    name = "event_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-events"
  }
}

# Sessions table - tracks individual interactions end-to-end
resource "aws_dynamodb_table" "sessions" {
  name           = "${var.project}-${var.environment}-sessions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "session_id"
  range_key      = "created_at"

  attribute {
    name = "session_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-sessions"
  }
}

# Dashboard table - pre-aggregated data for chart rendering
resource "aws_dynamodb_table" "dashboard" {
  name           = "${var.project}-${var.environment}-dashboard"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "metric_key"
  range_key      = "hour"

  attribute {
    name = "metric_key"
    type = "S"
  }

  attribute {
    name = "hour"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-dashboard"
  }
}
