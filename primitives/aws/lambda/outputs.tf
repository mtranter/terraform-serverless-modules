output "function" {
  value = aws_lambda_function.lambda
}

output "execution_role" {
  value = aws_iam_role.iam_for_lambda
}
