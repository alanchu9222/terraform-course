/*====
Glue database
====*/
resource "aws_glue_catalog_database" "AwsDataCatalog" {
  name = var.athena_database
}
  
/*====
Athena query database setup
====*/
resource "aws_athena_database" "dimeo_query_result" {
  name   = "dimeo_query_result"
  bucket = aws_s3_bucket.output_bucket.bucket
}

resource "aws_athena_workgroup" "primary" {
  name = "output_bucket"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.output_bucket.bucket}/output/"
    }
  }
}


/*====
Role to allow glue crawler to access glue services
====*/
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

resource "aws_iam_policy" "dimeo_crawler_policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:PutObject"
        ],
        "Resource": [
            "arn:aws:s3:::${var.data_source_bucket}/*"
        ]
    }    
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue_service_addition" {
    role = aws_iam_role.glue.name
    policy_arn = aws_iam_policy.dimeo_crawler_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_service" {
    role = aws_iam_role.glue.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
/*====
Glue crawler to that taps into the data source bucket 
====*/

resource "aws_glue_crawler" "raw-data-crawler" {
  database_name = aws_glue_catalog_database.AwsDataCatalog.name
  name          = "raw-data-crawler"
  role          = aws_iam_role.glue.arn

  s3_target {
    path = "s3://${var.data_source_bucket}/"
  }
}

/*====
S3 data source bucket 
====*/
resource "aws_s3_bucket" "input-bucket" {
  bucket = var.data_source_bucket
  acl    = "private"
  versioning {
    enabled = false
  }  
  tags = {
    Name  = "Raw bucket"
  }
}


# /*====
# S3 athena query output bucket 
# ====*/

resource "aws_s3_bucket" "output_bucket" {
  bucket = var.query_results_bucket
  acl    = "private"
  versioning {
    enabled = false
  }  
  tags = {
    Name  = "Transformed bucket"
  }
}

# /*====
# Defines a role that allows the user to access the Data Gateway and Jump Box EC2
# ====*/
# resource "aws_iam_role" "EC2AccessRole" {
#   name = "EC2AccessRole"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }

# resource "aws_iam_instance_profile" "DimeoEC2InstanceProfile" {
#   name = "datagen_profile"
#   role = aws_iam_role.EC2AccessRole.name
# }

# /*====
# Jump Box EC2
# ====*/
resource "aws_instance" "JumpBoxInstance" {

  // ami           = "ami-0c841cc412b3474b1"
  ami = var.regionspecific_windows_server_ami
  instance_type = "t2.medium"

  # the public SSH key
  key_name = var.key_name

  # the VPC subnet
  subnet_id = var.public_subnet_id

  # the security group
  vpc_security_group_ids = [var.dmz_security_group_id]

  # Tags
  tags = {
    Name = "Jump Box"
  }  
}

# /*====
# Data Gateway EC2
# ====*/

resource "aws_instance" "DataGatewayInstance" {
  ami           = var.regionspecific_windows_server_ami
  instance_type = "t2.medium"

  # the public SSH key
  key_name = var.key_name

  # the VPC subnet
  subnet_id = var.private_subnet_id

  # the security group
  vpc_security_group_ids = [var.dmz_security_group_id]

  # Tags
  tags = {
    Name = "Data Gateway"
  }  
}

# /*====
# Policy to allow EC2 Acccess Role to access S3
# ====*/
# resource "aws_iam_policy" "DatalakeAccessPolicy" {
#   name   = "datalake_access_policy"
#   path   = "/"
#   policy =  data.aws_iam_policy_document.DataLakeAccessPolicy.json
# }
# resource "aws_iam_role_policy_attachment" "EC2AccessRole-policy-attach" {
#   role       = aws_iam_role.EC2AccessRole.name
#   policy_arn = aws_iam_policy.DatalakeAccessPolicy.arn
# }

# data "aws_iam_policy_document" "DataLakeAccessPolicy" {
#   statement {
#     sid = "1"

#     actions = [
#       "s3:List*",
#       "s3:Get*",
#       "s3:AbortMultipartUpload",
#       "s3:CreateBucket",
#       "s3:PutObject",

#     ]

#     resources = [
#       "arn:aws:s3:::*",
#     ]
#   }

# }



