resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.key.id
  name          = "alias/dynamodb/${replace(var.name, ".", "_")}"
}

data "aws_caller_identity" "me" {}
data "aws_region" "current" {}

resource "aws_kms_key" "key" {
  description         = "Key for managing dynamo table ${var.name}"
  enable_key_rotation = true
  policy              = <<EOF
{
 "Version": "2012-10-17",
    "Id": "DynamoTable${var.name}KeyPolicy",
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
            "Sid" : "Allow access through Amazon DynamoDB for all principals in the account that are authorized to use Amazon DynamoDB",
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : "*"
            },
            "Action" : [ "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:CreateGrant", "kms:DescribeKey" ],
            "Resource" : "*",
            "Condition" : {
              "StringEquals" : {
                "kms:ViaService" : "dynamodb.${data.aws_region.current.name}.amazonaws.com",
                "kms:CallerAccount" : "${data.aws_caller_identity.me.account_id}"
              }
            }
          },
          {
            "Sid" : "Allow DynamoDB Service with service principal name dynamodb.amazonaws.com to describe the key directly",
            "Effect" : "Allow",
            "Principal" : {
              "Service" : "dynamodb.amazonaws.com"
            },
            "Action" : [ "kms:Describe*", "kms:Get*", "kms:List*" ],
            "Resource" : "*"
          }
    ]
}
EOF
}
