resource "aws_cloudwatch_event_rule" "rule" {
  name           = var.subscription_name
  event_bus_name = var.event_bus_name
  event_pattern  = <<EOF
{
  "detail-type": ${jsonencode(var.detail_types)}
}
EOF
}

resource "aws_cloudwatch_event_target" "target" {
  event_bus_name = var.event_bus_name
  arn            = var.target_arn
  rule           = aws_cloudwatch_event_rule.rule.name
}

