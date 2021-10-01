
locals {
  snowflake_role_name = "${var.job_name}SnowflakeAccessToS3"
}

data "aws_caller_identity" "me" {}

resource "aws_iam_role" "snowflake_external" {
  name = local.snowflake_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${snowflake_stage.stage.snowflake_iam_user}"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${snowflake_stage.stage.aws_external_id}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "snowflake" {
  name   = "SnowflakeCanS3"
  role   = aws_iam_role.snowflake_external.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
            ],
            "Resource": "arn:aws:s3:::${var.bucket_name}/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${var.bucket_name}"
        }
    ]
}
EOF
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_name

  queue {
    queue_arn = snowflake_pipe.pipe.notification_channel
    events = [
    "s3:ObjectCreated:*"]
  }
}

resource "snowflake_storage_integration" "s3" {
  name = upper(var.job_name)
  storage_allowed_locations = [
  "s3://${var.bucket_name}/"]
  storage_aws_role_arn = "arn:aws:iam::${data.aws_caller_identity.me.account_id}:role/${local.snowflake_role_name}"
  storage_provider     = "S3"
  type                 = "EXTERNAL_STAGE"

  lifecycle {
    ignore_changes = [
    type]
  }
}

resource "snowflake_stage" "stage" {
  depends_on = [
  snowflake_storage_integration.s3]
  database            = var.stage_database
  name                = var.stage_name
  schema              = var.stage_schema
  url                 = "s3://${var.bucket_name}${var.bucket_path}"
  file_format         = var.file_format
  storage_integration = snowflake_storage_integration.s3.name

}


resource "null_resource" "wait_for_iam" {
  // To deal with eventually consistent IAM
  depends_on = [aws_iam_role.snowflake_external, aws_iam_role_policy.snowflake]

  provisioner "local-exec" {
    command = "sleep 20"
  }
}

resource "snowflake_pipe" "pipe" {

  depends_on = [null_resource.wait_for_iam, snowflake_stage.stage]

  auto_ingest    = true
  copy_statement = var.copy_statement
  name           = var.pipe_name
  database       = var.pipe_database
  schema         = var.pipe_schema
}

