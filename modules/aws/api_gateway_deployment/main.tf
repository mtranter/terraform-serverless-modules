resource "random_pet" "deployment_trigger" {
  keepers = {
    trigger = var.trigger
  }
}

resource "aws_cloudformation_stack" "deploy" {
  name = "Deploy${var.service_name}Stack-${random_pet.deployment_trigger.id}"

  lifecycle {
    create_before_destroy = true
  }

  template_body = <<STACK
{
  "Resources" : {
        "serviceDeployment": {
        "Type" : "AWS::ApiGateway::Deployment",
        "Properties" : {
            "RestApiId": "${var.rest_api_id}",
            "StageName": "${var.stage_name}"
            }
        }
    }
}
STACK
}