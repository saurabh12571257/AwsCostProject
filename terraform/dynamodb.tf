resource "aws_dynamodb_table" "cost_history" {
  name         = "aws-cost-history"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "service_name"
  range_key = "date"

  attribute {
    name = "service_name"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }

  tags = {
    Name        = "aws-cost-history"
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }
}
