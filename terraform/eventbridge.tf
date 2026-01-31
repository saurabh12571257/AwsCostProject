resource "aws_cloudwatch_event_rule" "daily_cost_collection" {
  name        = "daily-cost-collection"
  description = "Trigger Lambda daily to collect AWS cost data"

  schedule_expression = "cron(0 1 * * ? *)"

  tags = {
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_cost_collection.name
  target_id = "CostAnalyzerLambda"
  arn       = aws_lambda_function.cost_analyzer.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_analyzer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_cost_collection.arn
}
