data "archive_file" "analysis_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/cost_analysis.py"
  output_path = "${path.module}/cost_analysis.zip"
}

resource "aws_lambda_function" "cost_analysis" {
  function_name = "aws-cost-analysis"
  runtime       = "python3.10"
  handler       = "cost_analysis.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn

  filename         = data.archive_file.analysis_lambda_zip.output_path
  source_code_hash = data.archive_file.analysis_lambda_zip.output_base64sha256

  timeout     = 60
  memory_size = 256

  environment {
    variables = {
      RAW_TABLE      = aws_dynamodb_table.cost_history.name
      ANALYSIS_TABLE = aws_dynamodb_table.cost_analysis.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.cost_analyzer_logs
  ]

  tags = {
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }
}
