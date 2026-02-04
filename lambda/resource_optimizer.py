data "archive_file" "resource_optimizer_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/resource_optimizer.py"
  output_path = "${path.module}/resource_optimizer.zip"
}

resource "aws_lambda_function" "resource_optimizer" {
  function_name = "aws-resource-optimizer"
  description   = "Detect unused AWS resources for cost optimization"

  runtime = "python3.10"
  handler = "resource_optimizer.lambda_handler"
  role   = aws_iam_role.lambda_execution_role.arn

  filename         = data.archive_file.resource_optimizer_zip.output_path
  source_code_hash = data.archive_file.resource_optimizer_zip.output_base64sha256

  timeout      = 300
  memory_size = 256

  environment {
    variables = {
      STOPPED_DAYS_THRESHOLD = "7"
      CPU_THRESHOLD          = "5"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.resource_optimizer_logs
  ]

  tags = {
    Project     = "aws-cost-optimizer"
    Environment = "dev"
  }
}
