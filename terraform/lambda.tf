resource "aws_lambda_function" "cost_analyzer" {
  function_name = "aws-cost-analyzer"
  description   = "Fetch daily AWS cost using Cost Explorer and store in DynamoDB and S3"

  runtime = "python3.10"
  handler = "cost_analyzer.lambda_handler"

  role = aws_iam_role.lambda_execution_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 60
  memory_size = 256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.cost_history.name
      S3_BUCKET      = aws_s3_bucket.cost_data_bucket.bucket
    }
  }

  tags = {
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }

  depends_on = [
    aws_cloudwatch_log_group.cost_analyzer_logs
  ]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/cost_analyzer.py"
  output_path = "${path.module}/lambda.zip"
}
