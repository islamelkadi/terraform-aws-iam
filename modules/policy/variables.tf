# IAM Policy Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# IAM policy configuration
variable "description" {
  description = "Description of the IAM policy"
  type        = string
  default     = ""
}

variable "path" {
  description = "Path in which to create the policy"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/.*/$|^/$", var.path))
    error_message = "Path must start and end with / or be just /"
  }
}

variable "policy_document" {
  description = "JSON-encoded IAM policy document"
  type        = string

  validation {
    condition     = can(jsondecode(var.policy_document))
    error_message = "Policy document must be valid JSON"
  }
}

# Attachment configuration
variable "attach_to_roles" {
  description = "List of IAM role names to attach this policy to"
  type        = list(string)
  default     = []
}

variable "attach_to_users" {
  description = "List of IAM user names to attach this policy to"
  type        = list(string)
  default     = []
}

variable "attach_to_groups" {
  description = "List of IAM group names to attach this policy to"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}
