resource "aws_cloudwatch_event_rule" "resource_optimizer_schedule" {
  name                = "resource-optimizer-schedule"
  description         = "Run unused resource detection"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "resource_optimizer_target" {
  rule      = aws_cloudwatch_event_rule.resource_optimizer_schedule.name
  target_id = "ResourceOptimizerLambda"
  arn       = aws_lambda_function.resource_optimizer.arn
}

resource "aws_lambda_permission" "allow_eventbridge_optimizer" {
  statement_id  = "AllowEventBridgeInvokeOptimizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resource_optimizer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.resource_optimizer_schedule.arn
}
