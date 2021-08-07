resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.key.id
  name          = "alias/s3/${replace(var.bucket, ".", "-")}"
}

data "aws_caller_identity" "me" {}
data "aws_region" "current" {}

resource "aws_kms_key" "key" {
	# checkov:skip=CKV_AWS_33: Using CallerAccount predicate
  description         = "Key for S3 bucket ${var.bucket}"
  enable_key_rotation = true
  policy              = <<EOF
{
 "Version": "2012-10-17",
    "Id": "S3${var.bucket}KeyPolicy",
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
            "Sid" : "Allow access through Amazon S3 for all principals in the account that are authorized to use Amazon Se",
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : "*"
            },
            "Action" : [ "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:CreateGrant", "kms:DescribeKey" ],
            "Resource" : "*",
            "Condition" : {
              "StringEquals" : {
                "kms:ViaService" : "s3.${data.aws_region.current.name}.amazonaws.com",
                "kms:CallerAccount" : "${data.aws_caller_identity.me.account_id}"
              }
            }
          }
    ]
}
EOF
}
