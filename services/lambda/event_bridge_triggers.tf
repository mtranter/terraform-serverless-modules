locals {
  eventbridge_triggers = { for k, v in coalesce(var.triggers["eventbridge"], tomap({})) : k => v }
}

module "event_bridge_subscription" {
  for_each = local.eventbridge_triggers
  source = "./../../modules/event_bus_subscription"
  detail_types = each.value.detail_types
  event_bus_name = each.value.event_bus_name
  lambda_arn = module.lambda.function.arn
  subscription_name = "${module.lambda.function.id}-${each.key}"
}