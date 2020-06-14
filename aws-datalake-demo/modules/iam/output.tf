output "api_user_access_key" {
  value = aws_iam_access_key.api_user_access_key.id
}

output "api_user_secret_key" {
  value = aws_iam_access_key.api_user_access_key.secret
}

