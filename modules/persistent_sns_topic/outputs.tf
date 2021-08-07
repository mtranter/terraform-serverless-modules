output "topic" {
  value = module.sns_topic
}

output "bucket" {
  value = module.bucket
}

output "firehose_stream" {
  value = module.firehose
}