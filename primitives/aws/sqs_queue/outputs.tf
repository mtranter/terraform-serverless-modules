output "queue" {
  value = aws_sqs_queue.queue
}

output "dlq" {
  value = var.create_dlq ? aws_sqs_queue.dead_letter_queue : null
}