locals {
  topic_name = "${replace(var.topic_name, ".", "_")}${var.is_fifo ? ".fifo" : ""}"
  dedup = coalesce(var.content_based_deduplication, var.is_fifo)
}

resource "aws_sns_topic" "topic" {
  name                        = local.topic_name
  fifo_topic                  = var.is_fifo
  content_based_deduplication = local.dedup
  kms_master_key_id           = aws_kms_key.key.id
  tags                        = var.tags
}
