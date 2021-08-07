module "sns_topic" {
  source = "./../../primitives/aws/sns_topic"
  is_fifo = false
  content_based_deduplication = var.content_based_deduplication
  topic_name = var.topic_name
  tags = var.tags
}

module "bucket" {
  source = "./../../primitives/aws/private_s3_bucket"
  bucket = lower("${var.topic_name}-persistent-sns-topic-storage")
  lifecycle_transitions = []
  versioning_enabled = false
}

module "firehose" {
  source = "./../firehose_s3_destination"
  bucket_arn = module.bucket.bucket.arn
  delivery_stream_name = "${var.topic_name}_persistent_sns_topic_transport"
  kms_key_arn = module.bucket.kms_key.arn
}

resource "aws_iam_role" "sns_can_firehose" {
  name = "SNS${var.topic_name}CanFirehose"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "can_firehose" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "firehose:DescribeDeliveryStream",
        "firehose:ListDeliveryStreams",
        "firehose:ListTagsForDeliveryStream",
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ],
      "Resource": [
        "${module.firehose.delivery_stream.arn}"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
  role = aws_iam_role.sns_can_firehose.id
}

resource "aws_sns_topic_subscription" "subscription" {
  endpoint = module.firehose.delivery_stream.arn
  protocol = "firehose"
  topic_arn = module.sns_topic.topic.arn
  subscription_role_arn = aws_iam_role.sns_can_firehose.arn
}