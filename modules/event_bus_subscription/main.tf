module "subscription" {
  source = "./../../primitives/aws/event_bridge_subscription"
  detail_types = var.detail_types
  event_bus_name = var.event_bus_name
  subscription_name = var.subscription_name
  target_arn = var.lambda_arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromC${var.subscription_name}"
  action        = "lambda:InvokeFunction"
  function_name = split(":", var.lambda_arn)[6]
  principal     = "events.amazonaws.com"
  source_arn    = module.subscription.rule.arn
}
