output "bus" {
  value = aws_cloudwatch_event_bus.bus
}

output "bus_archive" {
  value = aws_cloudwatch_event_archive.archive
}