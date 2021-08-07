locals {
  services_to_grant_to = [for arn in var.give_access_to : split(":", arn)[2]]
  unflattened_permissions = { for svc in local.services_to_grant_to : svc => flatten([
      for arn in var.give_access_to : [arn, "${arn}/*"] if split(":", arn)[2] == svc
    ])
  }
}

data "aws_iam_policy_document" "lambda_permissions" {

  dynamic statement {
    for_each = local.unflattened_permissions
    iterator = each
    content {
      sid       = "Can${title(each.key)}"
      actions   = ["${each.key}:*"]
      effect    = "Allow"
      resources = each.value
    }
  }
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name = "${local.function_name}ResourceAccess"
  policy = data.aws_iam_policy_document.lambda_permissions.json
  role   = module.lambda.execution_role.id
}
