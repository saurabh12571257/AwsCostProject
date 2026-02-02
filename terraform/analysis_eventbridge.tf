resource "aws_cloudwatch_event_rule" "daily_cost_analysis" {
  name                = "daily-cost-analysis"
  schedule_expression = "cron(0 2 * * ? *)"
}

resource "aws_cloudwatch_event_target" "analysis_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_cost_analysis.name
  target_id = "CostAnalysisLambda"
  arn       = aws_lambda_function.cost_analysis.arn
}

resource "aws_lambda_permission" "allow_eventbridge_analysis" {
  statement_id  = "AllowEventBridgeInvokeAnalysis"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_analysis.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_cost_analysis.arn
}
