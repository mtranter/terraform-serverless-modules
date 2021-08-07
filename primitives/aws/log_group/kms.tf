resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.key.id
  name          = "alias/log-group/${replace(trimprefix(var.name, "/"), ".", "-")}"
}

data "aws_caller_identity" "me" {}
data "aws_region" "current" {}

resource "aws_kms_key" "key" {
  description         = "Key for log group ${var.name}"
  enable_key_rotation = true
  policy              = <<EOF
{
 "Version": "2012-10-17",
    "Id": "LogGroup${replace(var.name, "/", "-")}KeyPolicy",
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
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.me.account_id}:log-group:${var.name}"
                }
            }
        }
    ]
}
EOF
}
