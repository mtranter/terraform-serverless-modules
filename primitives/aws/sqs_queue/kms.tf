resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.key.id
  name          = "alias/sqs/${replace(local.queue_name, ".", "-")}"
}

data "aws_caller_identity" "me" {}
data "aws_region" "current" {}

locals {
  sns_statement = <<EOF
,
        {
          "Sid" : "AllowSNS",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "sns.amazonaws.com"
          },
          "Action": [
            "kms:Decrypt",
            "kms:GenerateDataKey*"
          ],
          "Resource" : "*"
        }
EOF
  extra_policy = var.allow_sns ? "${local.sns_statement}" : ""
}

resource "aws_kms_key" "key" {
	# checkov:skip=CKV_AWS_33: Using CallerAccount predicate
  description         = "Key for sns topic ${local.queue_name}"
  enable_key_rotation = true
  policy              = <<EOF
{
 "Version": "2012-10-17",
    "Id": "SQS${local.queue_name}KeyPolicy",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.me.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
          "Sid" : "Allow access through Amazon SQS for all principals in the account that are authorized to use Amazon SQS",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : [ "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:CreateGrant", "kms:DescribeKey" ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "kms:ViaService" : "sqs.${data.aws_region.current.name}.amazonaws.com",
              "kms:CallerAccount" : "${data.aws_caller_identity.me.account_id}"
            }
          }
        }${local.extra_policy}
    ]
}
EOF
}
