resource "aws_sns_topic" "cost_alerts" {
  name = "aws-cost-alerts"

  tags = {
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }
}
