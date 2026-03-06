# Security Controls Validations
# Enforces security standards based on metadata module security controls
# Supports selective overrides with documented justification

locals {
  # Use security controls if provided, otherwise use permissive defaults
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = false
      require_encryption_at_rest    = false
      require_encryption_in_transit = false
      enable_kms_key_rotation       = false
    }
    logging = {
      require_cloudwatch_logs = false
      min_log_retention_days  = 1
      require_access_logging  = false
      require_flow_logs       = false
    }
    monitoring = {
      enable_xray_tracing         = false
      enable_enhanced_monitoring  = false
      enable_performance_insights = false
      require_cloudtrail          = false
    }
    network = {
      require_private_subnets = false
      require_vpc_endpoints   = false
      block_public_ingress    = false
      require_imdsv2          = false
    }
    compliance = {
      enable_point_in_time_recovery = false
      require_reserved_concurrency  = false
      enable_deletion_protection    = false
    }
    data_protection = {
      require_versioning  = false
      require_mfa_delete  = false
      require_backup      = false
      require_lifecycle   = false
      block_public_access = false
      require_replication = false
    }
    iam = {
      require_least_privilege     = false
      prohibit_wildcard_resources = false
      require_mfa                 = false
      max_session_duration        = 43200
    }
  }

  # Apply overrides to security controls
  # Controls are enforced UNLESS explicitly overridden with justification
  least_privilege_required = try(local.security_controls.iam.require_least_privilege, false) && !var.security_control_overrides.disable_least_privilege_check
  wildcard_prohibited      = try(local.security_controls.iam.prohibit_wildcard_resources, false) && !var.security_control_overrides.disable_wildcard_check

  # Check for wildcard resources in inline policies
  inline_policy_wildcards = [
    for policy_name, policy_doc in var.inline_policies :
    policy_name if can(regex("\"Resource\"\\s*:\\s*\"\\*\"", policy_doc))
  ]

  # Validation results
  least_privilege_validation_passed = !local.least_privilege_required || (length(var.managed_policy_arns) == 0 || length(var.inline_policies) > 0)
  wildcard_validation_passed        = !local.wildcard_prohibited || length(local.inline_policy_wildcards) == 0

  # Audit trail for overrides
  has_overrides = (
    var.security_control_overrides.disable_least_privilege_check ||
    var.security_control_overrides.disable_wildcard_check
  )

  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security Controls Check Block
check "security_controls_compliance" {
  assert {
    condition     = local.least_privilege_validation_passed
    error_message = "Security control violation: Least privilege is required. Avoid using only AWS managed policies without specific inline policies. Set security_control_overrides.disable_least_privilege_check=true with justification if this is intentional."
  }

  assert {
    condition     = local.wildcard_validation_passed
    error_message = "Security control violation: Wildcard resources (\"Resource\": \"*\") detected in inline policies: ${join(", ", local.inline_policy_wildcards)}. Use specific resource ARNs. Set security_control_overrides.disable_wildcard_check=true with justification if wildcard is required."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Please document the business reason in security_control_overrides.justification for audit compliance."
  }
}
