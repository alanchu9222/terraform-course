
resource "aws_glue_catalog_database" "AwsDataCatalog" {
  name = "dimeo-data"
}

resource "aws_athena_database" "query_result" {
  name   = "query_result"
  bucket = aws_s3_bucket.dimeo-tf-transformed-bucket.id
}


resource "aws_glue_crawler" "raw-data-crawler" {
  database_name = aws_glue_catalog_database.AwsDataCatalog.name
  name          = "raw-data-crawler"
  role          = aws_iam_role.glue.arn

  s3_target {
    path = "s3://${aws_s3_bucket.dimeo-tf-raw-bucket.bucket}/"
  }
}

resource "aws_s3_bucket" "dimeo-tf-raw-bucket" {
  bucket = "dimeo-tf-raw-bucket"
  acl    = "private"
  versioning {
    enabled = false
  }  
  tags = {
    Name        = "raw bucket"
  }
}
resource "aws_s3_bucket" "dimeo-tf-transformed-bucket" {
  bucket = "dimeo-tf-transformed-bucket"
  acl    = "private"
  versioning {
    enabled = false
  }  
  tags = {
    Name        = "transformed bucket"
  }
}


