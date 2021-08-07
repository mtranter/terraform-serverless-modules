

resource "aws_cloudwatch_event_bus" "bus" {
  name = var.name
  tags = var.tags
}

resource "aws_cloudwatch_event_archive" "archive" {
  name             = "${var.name}Archive"
  description      = "Archived events from ${var.name}"
  event_source_arn = aws_cloudwatch_event_bus.bus.arn
}
