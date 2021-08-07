output "topic" {
  value = aws_sns_topic.topic
}

output "kms_key" {
  value = aws_kms_key.key
}

output "kms_key_alias" {
  value = aws_kms_alias.alias
}