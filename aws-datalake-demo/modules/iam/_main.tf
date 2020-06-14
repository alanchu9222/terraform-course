/*====
Defines an API user that should be able to
- read+write to S3 bucket
- Send email via SES
====*/
resource "aws_iam_user" "api_user" {
  name = "${var.project_name}-api-${var.environment}"
}

resource "aws_iam_access_key" "api_user_access_key" {
  user = aws_iam_user.api_user.name
}

/* Apply S3 policy */
data "aws_iam_policy_document" "api_s3_policy" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*",
    ]
    actions = [
      "s3:*",
    ]
  }
}

resource "aws_iam_user_policy" "api_user_s3" {
  name   = "${var.project_name}-s3-${var.environment}-api-full-control"
  user   = aws_iam_user.api_user.name
  policy = data.aws_iam_policy_document.api_s3_policy.json
}

