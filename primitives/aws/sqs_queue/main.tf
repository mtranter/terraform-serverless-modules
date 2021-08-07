locals {
  queue_name = "${var.queue_name}${var.is_fifo ? ".fifo" : ""}"
  dedup      = coalesce(var.content_based_deduplication, var.is_fifo)
}

resource "aws_sqs_queue" "dead_letter_queue" {
  count = var.create_dlq ? 1 : 0
  name  = "${var.queue_name}-dlq"

  kms_master_key_id                 = aws_kms_key.key.id
  kms_data_key_reuse_period_seconds = 300

  fifo_queue                  = var.is_fifo
  deduplication_scope         = local.dedup ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_throughput_limit
  content_based_deduplication = local.dedup

  tags = var.tags
}

resource "aws_sqs_queue" "queue" {
  name                       = var.queue_name
  delay_seconds              = var.delay_seconds
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  redrive_policy             = var.create_dlq ? "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter_queue[0].arn}\",\"maxReceiveCount\":100}" : null

  kms_master_key_id                 = aws_kms_key.key.id
  kms_data_key_reuse_period_seconds = 300

  fifo_queue                  = var.is_fifo
  deduplication_scope         = local.dedup ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_throughput_limit
  content_based_deduplication = local.dedup

  tags = var.tags
}
