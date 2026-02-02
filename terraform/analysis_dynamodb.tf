resource "aws_dynamodb_table" "cost_analysis" {
  name         = "aws-cost-analysis"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "analysis_type"
  range_key = "date"

  attribute {
    name = "analysis_type"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }

  tags = {
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }
}
