output "aws_buckets_arn" {
  value = [aws_s3_bucket.thumbnails.arn, aws_s3_bucket.images.arn]
}
output "aws_lambda_function_arn" {
  value = aws_lambda_function.compression.arn
}
output "aws_lambda_layer_version_version" {
  value = aws_lambda_layer_version.sharp.version
}