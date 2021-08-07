resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.name}ExecutionRole"
  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_lambda_function" "lambda" {
  function_name                  = var.name
  description                    = var.description
  handler                        = var.handler
  role                           = aws_iam_role.iam_for_lambda.arn
  runtime                        = var.runtime
  filename                       = var.filename
  source_code_hash               = filebase64sha256(var.filename)
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  layers                         = var.layers
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrency

  dynamic tracing_config {
    for_each = var.xray_enabled ? [
      1] : []
    content {
      mode = "Active"
    }
  }

  dynamic vpc_config {
    for_each = var.vpc_config == null ? [] : [
      var.vpc_config]
    content {
      vpc_id             = var.vpc_config.vpc_id
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }

  dynamic file_system_config {
    for_each = var.file_system_config == null ? [] : [
      1]
    content {
      arn              = var.file_system_config.efs_access_point_arn
      local_mount_path = var.file_system_config.local_mount_path
    }
  }
  dynamic "dead_letter_config" {
    for_each = var.dlq_arn != null ? [
      1] : []
    content {
      target_arn = var.dlq_arn
    }
  }

  environment {
    variables = var.environment_vars
  }

  tags = var.tags
}