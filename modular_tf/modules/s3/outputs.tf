output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_url" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}