data "archive_file" "snailcode" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/snailmail.zip"
}
resource "aws_lambda_function" "snailmail" {
  filename      = "${path.module}/lambda/snailmail.zip"
  function_name = "snailmail"
  role          = aws_iam_role.snailfnrole.arn
  handler       = "snailmail.handler"

  runtime = "nodejs18.x"
}
resource "aws_lambda_event_source_mapping" "triggerfromqueue" {
  event_source_arn = aws_sqs_queue.snail.arn
  function_name    = aws_lambda_function.snailmail.arn
}
