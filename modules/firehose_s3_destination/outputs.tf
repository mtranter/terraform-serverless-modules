output "delivery_stream" {
  value = aws_kinesis_firehose_delivery_stream.stream
}

output "delivery_stream_role" {
  value = aws_iam_role.firehose_role
}