output "api" {
  value = {for k, v in var.api : k => {
    rest_api_id = data.aws_api_gateway_rest_api.api.id
    resource_id = data.aws_api_gateway_resource.resources[k].id
    methods     = v.methods
  }
  }
}