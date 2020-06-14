resource "aws_iam_role" "EC2AccessRole" {
  name = "EC2AccessRole"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role" "glue" {
  name = "AWSGlueServiceRoleDefault"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# resource "aws_iam_role_policy" "my_s3_policy" {
#   name = "my_s3_policy"
#   role = aws_iam_role.glue.name
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:*"
#       ],
#       "Resource": [
#         "arn:aws:s3:::my_bucket",
#         "arn:aws:s3:::my_bucket/*"
#       ]
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_role_policy_attachment" "glue_service" {
    role = aws_iam_role.glue.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy_document" "DataLakeAccessPolicy" {
  statement {
    sid = "1"

    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:AbortMultipartUpload",
      "s3:CreateBucket",
      "s3:PutObject",

    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

}



resource "aws_iam_policy" "DataLakeAccessPolicy" {
  name   = "access_policy"
  path   = "/"
  policy =  data.aws_iam_policy_document.DataLakeAccessPolicy.json
}

resource "aws_iam_role_policy_attachment" "EC2AccessRole-policy-attach" {
  role       = aws_iam_role.EC2AccessRole.name
  policy_arn = aws_iam_policy.DataLakeAccessPolicy.arn
}

