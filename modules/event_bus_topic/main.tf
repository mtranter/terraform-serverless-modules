data "aws_iam_policy_document" "can_publish" {

  statement {
    sid = "AllowPutRuleForOwnedRules"

    actions = [
      "events:PutEvents",
    ]
    
    resources = [
      var.event_bus_arn
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