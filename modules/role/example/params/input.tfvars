namespace   = "example"
environment = "dev"
name        = "lambda-execution"
region      = "us-east-1"

description           = "Lambda execution role"
principal_type        = "Service"
principal_identifiers = ["lambda.amazonaws.com"]

managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]

max_session_duration = 3600

tags = {
  Example = "IAM_ROLE"
}
