variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Name for the IAM role"
  type        = string
  default     = "lambda-execution"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default     = "Lambda execution role"
}

variable "principal_type" {
  description = "Type of principal for assume role policy"
  type        = string
  default     = "Service"
}

variable "principal_identifiers" {
  description = "List of principal identifiers"
  type        = list(string)
  default     = ["lambda.amazonaws.com"]
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Example = "IAM_ROLE"
  }
}
