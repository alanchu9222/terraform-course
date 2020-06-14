/*====
S3 Bucket to store the App and its assets
=====*/
resource "aws_s3_bucket" "dimeo_tf_test_app_bucket" {
  bucket = var.bucket_name
  acl    = "private"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

