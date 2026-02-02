resource "aws_cloudwatch_log_group" "cost_analyzer_logs" {
  name              = "/aws/lambda/aws-cost-analyzer"
  retention_in_days = 14

  tags = {
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_log_group" "cost_analysis_logs" {
  name              = "/aws/lambda/aws-cost-analysis"
  retention_in_days = 14

  tags = {
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }
}
