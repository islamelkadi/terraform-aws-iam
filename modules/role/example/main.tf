# Basic IAM Role Example

module "lambda_role" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description

  principal_type        = var.principal_type
  principal_identifiers = var.principal_identifiers

  managed_policy_arns = var.managed_policy_arns

  inline_policies = {
    "cloudwatch-logs" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:*:log-group:/aws/lambda/${var.namespace}-${var.environment}-${var.name}*"
      }]
    })
  }

  max_session_duration = var.max_session_duration

  tags = var.tags
}
