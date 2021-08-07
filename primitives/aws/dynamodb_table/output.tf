output "table" {
  value = aws_dynamodb_table.table
}

output "kms_key" {
  value = aws_kms_key.key
}

output "kms_key_alias" {
  value = aws_kms_alias.alias
}