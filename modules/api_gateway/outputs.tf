output "api_gateway" {
  value = aws_api_gateway_rest_api.api
}

output "default_stage" {
  value = aws_api_gateway_stage.default_stage
}