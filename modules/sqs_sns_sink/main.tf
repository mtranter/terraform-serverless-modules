
module "queue" {
  source                      = "./../../primitives/aws/sqs_queue"
  queue_name                  = var.queue_name
  is_fifo                     = var.is_fifo
  create_dlq                  = var.create_dlq
  tags                        = var.tags
  allow_sns                   = true
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  content_based_deduplication = var.content_based_deduplication
  deduplication_scope         = var.deduplication_scope
  fifo_throughput_limit       = var.fifo_throughput_limit
}

resource "aws_sns_topic_subscription" "sqs_target" {
  topic_arn = var.sns_topic_arn
  protocol  = "sqs"
  endpoint  = module.queue.queue.arn
  filter_policy = var.filter_policy == null ? null : jsonencode(var.filter_policy)
  raw_message_delivery = true
}


resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = module.queue.queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${module.queue.queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${var.sns_topic_arn}"
        }
      }
    }
  ]
}
POLICY
}