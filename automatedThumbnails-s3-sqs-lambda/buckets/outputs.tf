output "S3_Bucket_ID" {
  value = [aws_s3_bucket.images.id, aws_s3_bucket.thumbnails.id]
}