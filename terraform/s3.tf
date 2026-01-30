resource "aws_s3_bucket" "cost_data_bucket" {
  bucket = "aws-cost-data-${random_id.bucket_id.hex}"

  tags = {
    Name        = "aws-cost-data"
    Project     = "aws-cost-optimizer"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "cost_data_versioning" {
  bucket = aws_s3_bucket.cost_data_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cost_data_block_public" {
  bucket = aws_s3_bucket.cost_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_id" "bucket_id" {
  byte_length = 4
}
