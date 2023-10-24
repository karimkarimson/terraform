# Automatic Thumbnail Creation

On an upload of a .jpg the S3 Bucket sends a message to SQS, which forwards to Lambda. Lambda then creates a thumbnail and uploads it a thumbnail Bucket (S3).