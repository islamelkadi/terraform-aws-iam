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
  description = "Name for the IAM policy"
  type        = string
  default     = "corporate-actions-access"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Access policy for Corporate Actions Orchestrator"
}

variable "path" {
  description = "Path in which to create the policy"
  type        = string
  default     = "/corporate-actions/"
}

variable "attach_to_roles" {
  description = "List of IAM role names to attach this policy to"
  type        = list(string)
  default     = ["example-lambda-role"]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Example = "IAM_POLICY"
  }
}
