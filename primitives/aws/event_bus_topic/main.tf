data "aws_caller_identity" "me" {}

data "aws_region" "here" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "can_publish" {

  statement {
    sid = "AllowPutRuleForOwnedRules"

    actions = [
      "events:PutEvents",
    ]
    
    resources = [
      "arn:aws:events:${data.aws_region.here.name}:${data.aws_caller_identity.me.account_id}:event-bus/${var.event_bus_name}"
    ]

    condition {
      test     = "StringLike"
      values   = [var.event_source_name]
      variable = "events:source"
    }

    condition {
      test     = "StringLike"
      values   = [var.event_type]
      variable = "events:detail-type"
    }
  }
}

resource "aws_iam_role_policy" "can_event_bus" {
  role = var.role_id
  policy = data.aws_iam_policy_document.can_publish.json
}