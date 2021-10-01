

resource "aws_iam_role" "firehose_role" {
  name = var.delivery_stream_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "1"
    }
  ]
}
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "stream" {
  name = var.delivery_stream_name
  destination = "s3"

  s3_configuration {
    role_arn = aws_iam_role.firehose_role.arn
    bucket_arn = var.bucket_arn
  }

}

data "aws_region" "current" {}
data "aws_caller_identity" "me" {}

module "cloudwatch_logs" {
  source = "./../../primitives/aws/log_group"
  name = "${var.delivery_stream_name}Logs"
  retention_days = 7
}

resource "aws_iam_role_policy" "policy" {
  name = var.delivery_stream_name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement":
    [
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${var.bucket_arn}",
                "${var.bucket_arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:stream/${var.delivery_stream_name}"
        },
        {
           "Effect": "Allow",
           "Action": [
               "kms:Decrypt",
               "kms:GenerateDataKey"
           ],
           "Resource": [
               "${var.kms_key_arn}"
           ]
        },
        {
           "Effect": "Allow",
           "Action": [
               "logs:PutLogEvents"
           ],
           "Resource": [
               "${module.cloudwatch_logs.log_group.arn}:*"
           ]
        }
    ]
}
EOF
  role = aws_iam_role.firehose_role.id
}