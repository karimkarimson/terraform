terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

#* SQS-Queue
resource "aws_sqs_queue" "fromS3toLambda" {
  name = "s3-event-notification-queue"
}
#* SQS-Queue-Policy
data "aws_iam_policy_document" "sqspol" {
  statement {
    sid = "lambda-access"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    resources = [aws_sqs_queue.fromS3toLambda.arn]
  }

  statement {
    sid = "s3-access"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes"
    ]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    resources = [aws_sqs_queue.fromS3toLambda.arn]
  }
}

resource "aws_sqs_queue_policy" "accessfromservices" {
  queue_url = aws_sqs_queue.fromS3toLambda.id
  policy    = data.aws_iam_policy_document.sqspol.json
}

#* S3-Buckets
resource "aws_s3_bucket" "images" {
  bucket = "images-4569344686454j"

  tags = {
    Name = "images"
  }
}
resource "aws_s3_bucket" "thumbnails" {
  bucket = "thumbnails-913466129429x"

  tags = {
    Name = "thumbnails"
  }
}

#* Bucket-Event-Trigger
resource "aws_s3_bucket_notification" "sendinfotoqueue" {
  bucket     = aws_s3_bucket.images.id
  depends_on = [aws_sqs_queue.fromS3toLambda, aws_sqs_queue_policy.accessfromservices]

  queue {
    queue_arn = aws_sqs_queue.fromS3toLambda.arn
    events = [
      "s3:ObjectCreated:Put",
      "s3:ObjectCreated:Post"
    ]
    filter_suffix = ".jpg"
  }
}


#* Policies & Roles - Definitions
# policies def and creation
data "aws_iam_policy_document" "logging" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:eu-central-1:475032304489:*"]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:eu-central-1:475032304489:log-group:/aws/lambda/compressionlambda:*"
    ]
  }
}
resource "aws_iam_policy" "loggpol" {
  name        = "logging-policy"
  description = "A logging policy"
  policy      = data.aws_iam_policy_document.logging.json
}
data "aws_iam_policy_document" "bucketpolicies" {
  depends_on = [aws_s3_bucket.images, aws_s3_bucket.thumbnails]
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    sid       = "bucketPolicies"
    resources = [aws_s3_bucket.thumbnails.arn, aws_s3_bucket.images.arn]
  }
}
resource "aws_iam_policy" "bucketpol" {
  name        = "bucket-policy"
  description = "A bucket policy"
  policy      = data.aws_iam_policy_document.bucketpolicies.json
}
data "aws_iam_policy_document" "queuepolicies" {
  depends_on = [aws_s3_bucket.images, aws_s3_bucket.thumbnails]
  statement {
    actions = [
      "sqs:CreateQueue",
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    sid       = "AllowSQSAction"
    resources = [aws_s3_bucket.thumbnails.arn, aws_s3_bucket.images.arn, aws_sqs_queue.fromS3toLambda.arn]
  }
}
resource "aws_iam_policy" "queuepol" {
  name        = "queue-policy"
  description = "A sqs policy"
  policy      = data.aws_iam_policy_document.queuepolicies.json
}
data "aws_iam_policy_document" "basicfnpol" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

#* Create roles in AWS
# basic role for Lambda
resource "aws_iam_role" "compressionfnrole" {
  name               = "compressionfnrole"
  assume_role_policy = data.aws_iam_policy_document.basicfnpol.json
}
# add roles for lambda 
resource "aws_iam_role_policy_attachment" "sqattach" {
  role       = aws_iam_role.compressionfnrole.name
  policy_arn = aws_iam_policy.queuepol.arn
}
resource "aws_iam_role_policy_attachment" "bucketattach" {
  role       = aws_iam_role.compressionfnrole.name
  policy_arn = aws_iam_policy.bucketpol.arn
}
resource "aws_iam_role_policy_attachment" "logattach" {
  role       = aws_iam_role.compressionfnrole.name
  policy_arn = aws_iam_policy.loggpol.arn
}

#* Lambda-Function with Layer
# data "archive_file" "indexjs" {
#   type        = "zip"
#   source_file = "code.zip"
#   output_path = "lambda_function_payload.zip"
# }

resource "aws_lambda_layer_version" "sharp" {
  filename   = "sharp-layer.zip"
  layer_name = "sharp"

  compatible_runtimes = ["nodejs18.x"]
}

resource "aws_lambda_function" "compression" {
  filename      = "code.zip"
  function_name = "compressionlambda"
  role          = aws_iam_role.compressionfnrole.arn
  handler       = "index.handler"
  layers        = [aws_lambda_layer_version.sharp.arn]

  runtime = "nodejs18.x"
}
resource "aws_lambda_event_source_mapping" "triggerfromqueue" {
  event_source_arn = aws_sqs_queue.fromS3toLambda.arn
  function_name    = aws_lambda_function.compression.arn
}