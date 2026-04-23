output "kb_source_bucket_name" {
  value = aws_s3_bucket.kb_source.bucket
}

output "kb_source_bucket_arn" {
  value = aws_s3_bucket.kb_source.arn
}
