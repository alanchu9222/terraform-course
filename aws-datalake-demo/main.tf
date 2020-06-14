
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

# module "athena_gateway" {
#   source       = "../modules/athena_gateway"
#   project_name = var.project_name
#   environment  = "production"
#   key_name     = aws_key_pair.key.id
#   public_subnet_id = module.networking.public_subnets_id[0]
#   private_subnet_id = module.networking.private_subnets_id[0]
#   athena_database = "dimeo-data"
#   query_results_bucket = "dimeo-demo-query-results-bucket"
#   data_source_bucket = "dimeo-demo-raw-data-bucket"
#   regionspecific_windows_server_ami = var.windows_server_ami
#   dmz_security_group_id = module.networking.default_sg_id
# }

resource "aws_glue_catalog_database" "AwsDataCatalog" {
  name = "dimeo-data"
}


/*====
Athena query setup
====*/
resource "aws_athena_database" "query_result" {
  name   = "query_result"
  bucket = aws_s3_bucket.output_bucket.bucket
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

/*====
Glue crawler to that taps into the data source bucket 
====*/

resource "aws_glue_crawler" "raw-data-crawler" {
  database_name = aws_glue_catalog_database.AwsDataCatalog.name
  name          = "raw-data-crawler"
  role          = aws_iam_role.glue.arn

  s3_target {
    path = "s3://aws_s3_bucket.dimeo-demo-raw-data-bucket.bucket/"
  }
}

/*====
S3 data source bucket 
====*/
resource "aws_s3_bucket" "dimeo-tf-raw-bucket" {
  bucket = "dimeo-demo-raw-data-bucket"
  acl    = "private"
  versioning {
    enabled = false
  }  
  tags = {
    Name        = "Raw bucket"
  }
}


# /*====
# S3 athena query output bucket 
# ====*/

resource "aws_s3_bucket" "output_bucket" {
  bucket = "dimeo-demo-query-results-bucket"
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
# Jump Box EC2
# ====*/
resource "aws_instance" "JumpBoxInstance" {

  // ami           = "ami-0c841cc412b3474b1"
  ami = var.windows_server_ami
  instance_type = "t2.medium"

  # the public SSH key
  key_name = aws_key_pair.key.key_name

  # the VPC subnet
  subnet_id = module.datalake_network.datalake_public_subnet_id
  #subnet_id = aws_subnet.Subnet1.id

  # the security group
  vpc_security_group_ids = [module.datalake_network.default_sg_id]
  #vpc_security_group_ids = [aws_security_group.DMZSecurityGroup.id]

  # Tags
  tags = {
    Name = "Jump Box"
  }  
}

# /*====
# Data Gateway EC2
# ====*/

resource "aws_instance" "DataGatewayInstance" {
  ami           = var.windows_server_ami
  instance_type = "t2.medium"

  # the public SSH key
  key_name = aws_key_pair.key.key_name

  # the VPC subnet
  subnet_id = module.datalake_network.datalake_private_subnet_id
  #subnet_id = aws_subnet.Subnet3.id

  # the security group
  vpc_security_group_ids = [module.datalake_network.datagateway_sg_id]
  #vpc_security_group_ids = [aws_security_group.DMZSecurityGroup.id]

  # Tags
  tags = {
    Name = "Data Gateway"
  }  
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

resource "aws_iam_role_policy_attachment" "glue_service" {
    role = aws_iam_role.glue.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
