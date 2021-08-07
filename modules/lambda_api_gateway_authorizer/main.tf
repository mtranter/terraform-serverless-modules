resource "aws_iam_role" "authorizer_role" {
  name = "${var.authorizer_name}ApiGatewayAuthorizer"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authorizer_role_policy" {
  name = "${var.authorizer_name}ApiGatewayAuthorizer"
  role = aws_iam_role.authorizer_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${var.function_arn}"
    }
  ]
}
EOF
}

resource "aws_api_gateway_authorizer" "auth" {
  name = var.authorizer_name
  rest_api_id = var.rest_api_id
  authorizer_uri = var.invoke_arn
  authorizer_credentials = aws_iam_role.authorizer_role.arn
}