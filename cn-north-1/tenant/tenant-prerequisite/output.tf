output "bucket_name" {
  value = aws_s3_bucket.wsa_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.wsa_bucket.arn
}
