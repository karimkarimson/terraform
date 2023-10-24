resource "aws_sqs_queue" "snail" {
  name = "snail-test-queue"
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
    resources = [aws_sqs_queue.snail.arn]
  }
}

resource "aws_sqs_queue_policy" "lambdaaccesspolicy" {
  queue_url = aws_sqs_queue.snail.id
  policy    = data.aws_iam_policy_document.sqspol.json
}