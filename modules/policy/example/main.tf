# Basic IAM Policy Example

module "corporate_actions_policy" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description
  path        = var.path

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.region}:123456789012:table/corporate-actions",
          "arn:aws:dynamodb:${var.region}:123456789012:table/corporate-actions/index/*"
        ]
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::corporate-actions-raw-feeds",
          "arn:aws:s3:::corporate-actions-raw-feeds/*"
        ]
      }
    ]
  })

  attach_to_roles = var.attach_to_roles

  tags = var.tags
}
