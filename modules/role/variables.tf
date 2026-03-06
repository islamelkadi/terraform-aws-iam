# IAM Role Module Variables

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
  description = "Name of the IAM role"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# IAM role specific variables

# New simplified assume role policy configuration
variable "principal_type" {
  description = "Type of principal that can assume this role (Service, AWS, Federated). Required if assume_role_policy is not provided"
  type        = string
  default     = null

  validation {
    condition     = var.principal_type == null || try(contains(["Service", "AWS", "Federated"], var.principal_type), false)
    error_message = "Principal type must be one of: Service, AWS, Federated"
  }
}

variable "principal_identifiers" {
  description = "List of principal identifiers (e.g., ['lambda.amazonaws.com'] for Service, ['arn:aws:iam::123456789012:root'] for AWS). Required if assume_role_policy is not provided"
  type        = list(string)
  default     = null
}

variable "assume_role_actions" {
  description = "List of actions allowed in the assume role policy"
  type        = list(string)
  default     = ["sts:AssumeRole"]
}

variable "assume_role_conditions" {
  description = "Optional conditions for the assume role policy"
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []
}

# Legacy assume role policy (for backward compatibility)
variable "assume_role_policy" {
  description = "JSON-encoded assume role policy document. If not provided, will be generated from principal_type and principal_identifiers"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds (1 hour to 12 hours)"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 (1 hour) and 43200 (12 hours) seconds"
  }
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = false
}

variable "path" {
  description = "Path in which to create the role"
  type        = string
  default     = "/"
}

variable "permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the role"
  type        = string
  default     = null
}

# Policy attachment variables
variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to policy documents (JSON)"
  type        = map(string)
  default     = {}
}

variable "custom_policy_arns" {
  description = "Map of custom policy ARNs to attach to the role (key = policy name, value = policy ARN)"
  type        = map(string)
  default     = {}
}

variable "policy_attachments" {
  description = "List of policy module outputs to attach to the role. Each item should be a policy module output containing policy_arn"
  type = list(object({
    policy_arn = string
  }))
  default = []
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    network = object({
      require_private_subnets = bool
      require_vpc_endpoints   = bool
      block_public_ingress    = bool
      require_imdsv2          = bool
    })
    compliance = object({
      enable_point_in_time_recovery = bool
      require_reserved_concurrency  = bool
      enable_deletion_protection    = bool
    })
    data_protection = object({
      require_versioning  = bool
      require_mfa_delete  = bool
      require_backup      = bool
      require_lifecycle   = bool
      block_public_access = bool
      require_replication = bool
    })
    iam = optional(object({
      require_least_privilege     = bool
      prohibit_wildcard_resources = bool
      require_mfa                 = bool
      max_session_duration        = number
      }), {
      require_least_privilege     = false
      prohibit_wildcard_resources = false
      require_mfa                 = false
      max_session_duration        = 43200
    })
  })
  default = null
}

variable "security_control_overrides" {
  description = "Override specific security controls with documented justification"
  type = object({
    disable_least_privilege_check = optional(bool, false)
    disable_wildcard_check        = optional(bool, false)
    justification                 = optional(string, "")
  })
  default = {
    disable_least_privilege_check = false
    disable_wildcard_check        = false
    justification                 = ""
  }
}
