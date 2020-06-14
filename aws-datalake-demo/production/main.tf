
/*====
Variables used across all modules
======*/
locals {
  // availability_zones = ["ap-southeast-2a", "ap-southeast-2b"]
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  environment        = "production"
}

# Default provider configuration
provider "aws" {
  region = var.region
}

resource "aws_key_pair" "key" {
  key_name   = "production_key_dimeo"
  public_key = file("test-key.pub")
}


/*====
TODO - Inputs for this module not used - have to fix this
======*/
module "datalake_network" {
  source               = "../modules/datalake_network"
  project_name         = var.project_name
  environment          = local.environment
  vpc_cidr             = "10.1.0.0/16"
  public_subnets_cidr  = ["10.1.3.0/24", "10.1.4.0/24"]
  private_subnets_cidr = ["10.1.30.0/24", "10.1.40.0/24"]
  region               = var.region
  availability_zones   = local.availability_zones
  key_name             = "production_key_tb"
}


module "s3" {
  source       = "../modules/s3"
  project_name = var.project_name
  environment  = "production"
  bucket_name  = "dimeo-production-raw-data-bucket"
}


module "athena_gateway" {
  source       = "../modules/athena_gateway"
  project_name = var.project_name
  environment  = "production"
  key_name     = aws_key_pair.key.id
  public_subnet_id = module.datalake_network.datalake_public_subnet_id
  private_subnet_id = module.datalake_network.datalake_private_subnet_id
  athena_database = "dimeo-data"
  query_results_bucket = "dimeo-demo-query-results-bucket"
  data_source_bucket = "dimeo-demo-raw-data-bucket"
  regionspecific_windows_server_ami = var.windows_server_ami
  dmz_security_group_id = module.datalake_network.default_sg_id
  datagateway_security_group_id = module.datalake_network.datagateway_sg_id
}

# /*====
# Defines a role that allows the user to access the Data Gateway and Jump Box EC2
# ====*/
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


# /*====
# Policy to allow EC2 Acccess Role to access S3
# ====*/
resource "aws_iam_policy" "DataLakeAccessPolicy" {
  name   = "datalake_access_policy"
  path   = "/"
  policy =  data.aws_iam_policy_document.DataLakeAccessPolicy.json
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

resource "aws_iam_role_policy_attachment" "EC2AccessRole-policy-attach" {
  role       = aws_iam_role.EC2AccessRole.name
  policy_arn = aws_iam_policy.DataLakeAccessPolicy.arn
}


