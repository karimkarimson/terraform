output "sqs_queue_url" {
  value = aws_sqs_queue.snail.id
}