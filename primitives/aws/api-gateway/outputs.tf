output "api" {
  value = aws_api_gateway_rest_api.api
}

output "live_stage" {
  value = aws_api_gateway_stage.default_stage
}

output "deployment" {
  value = aws_api_gateway_deployment.deployment
}

output "access_logs_log_group" {
  value = local.log_group_name
}