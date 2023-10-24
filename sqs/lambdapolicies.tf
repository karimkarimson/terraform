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
      "arn:aws:logs:eu-central-1:475032304489:log-group:/aws/lambda/snailmail:*"
    ]
  }
}
resource "aws_iam_policy" "loggpol" {
  name        = "logging-policy"
  description = "A logging policy"
  policy      = data.aws_iam_policy_document.logging.json
}
data "aws_iam_policy_document" "queuepolicies" {
  statement {
    actions = [
      "sqs:CreateQueue",
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    sid       = "AllowSQSAction"
    resources = [aws_sqs_queue.snail.arn]
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
resource "aws_iam_role" "snailfnrole" {
  name               = "snailfnrole"
  assume_role_policy = data.aws_iam_policy_document.basicfnpol.json
}
# add roles for lambda 
resource "aws_iam_role_policy_attachment" "sqattach" {
  role       = aws_iam_role.snailfnrole.name
  policy_arn = aws_iam_policy.queuepol.arn
}
resource "aws_iam_role_policy_attachment" "logattach" {
  role       = aws_iam_role.snailfnrole.name
  policy_arn = aws_iam_policy.loggpol.arn
}