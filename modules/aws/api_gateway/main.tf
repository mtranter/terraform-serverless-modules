resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.api_gw_account.arn
}

resource "aws_iam_role" "api_gw_account" {
  name = "ApiGatewayCloudwatch"

  tags = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "can_log" {
  role       = aws_iam_role.api_gw_account.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_gw_name
  description = var.api_gw_description
  tags        = var.tags
}

resource "aws_api_gateway_resource" "healthcheck" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.healthcheck_path
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "get_healthcheck" {
  # checkov:skip=CKV_AWS_59: Healthcheck only
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.healthcheck.id
  rest_api_id   = aws_api_gateway_rest_api.api.id

}

resource "aws_api_gateway_integration" "healthcheck" {
  http_method       = aws_api_gateway_method.get_healthcheck.http_method
  resource_id       = aws_api_gateway_resource.healthcheck.id
  rest_api_id       = aws_api_gateway_rest_api.api.id
  type              = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "healthcheck_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.healthcheck.id
  http_method = aws_api_gateway_method.get_healthcheck.http_method
  status_code = 200

}

resource "aws_api_gateway_integration_response" "healthcheck_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.healthcheck.id
  http_method = aws_api_gateway_method.get_healthcheck.http_method
  status_code = aws_api_gateway_method_response.healthcheck_response_200.status_code

  response_templates = {
    "application/json" = jsonencode(var.health_check_response)
  }
}

resource "null_resource" "sleep" {

  provisioner "local-exec" {
    command = "sleep 5"
  }

  depends_on = [
    aws_api_gateway_integration_response.healthcheck_response,
    aws_api_gateway_integration.healthcheck
  ]
}

resource "aws_api_gateway_deployment" "initial_deploy" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true

  }

  depends_on = [
    aws_api_gateway_integration_response.healthcheck_response,
    aws_api_gateway_integration.healthcheck
  ]
}

module "log_group" {
  source = "./../../primitives/aws/log_group"
  name   = "/aws/api-gateway-stage/${var.default_stage_name}/access_logs"
}



resource "aws_api_gateway_stage" "default_stage" {
  deployment_id         = aws_api_gateway_deployment.initial_deploy.id
  rest_api_id           = aws_api_gateway_rest_api.api.id
  stage_name            = var.default_stage_name
  xray_tracing_enabled  = var.xray_enabled
  cache_cluster_enabled = var.enable_caching
  cache_cluster_size    = var.cache_cluster_size

  access_log_settings {
    destination_arn = module.log_group.log_group.arn
    format          = replace(<<EOF
{ "requestId":"$context.requestId", 
  "ip": "$context.identity.sourceIp", 
  "caller":"$context.identity.caller", 
  "user":"$context.identity.user", 
  "requestTime":"$context.requestTime", 
  "httpMethod":"$context.httpMethod", 
  "resourcePath":"$context.resourcePath", 
  "path":"$context.path", 
  "status":"$context.status", 
  "protocol":"$context.protocol", 
  "error": "$context.error.message"
}
EOF
,"\n", "")
  }

  lifecycle {
    ignore_changes = [
      deployment_id]
  }
}

resource "aws_api_gateway_method_settings" "api_settings" {
  method_path = "*/*"
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.default_stage.stage_name
  settings {
    logging_level   = "INFO"
    metrics_enabled = true
    data_trace_enabled = true
  }
}