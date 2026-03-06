# Local values for naming and tagging

locals {
  # Use metadata module for naming
  role_name = module.metadata.resource_prefix

  # Create tags with metadata information
  tags = merge(
    module.metadata.security_tags,
    var.tags,
    {
      Name   = module.metadata.resource_prefix
      Module = "terraform-aws-iam-role"
    }
  )

  # Validation: Either assume_role_policy OR (principal_type + principal_identifiers) must be provided
  has_legacy_policy = var.assume_role_policy != null
  has_new_config    = var.principal_type != null && var.principal_identifiers != null
  has_valid_config  = local.has_legacy_policy || local.has_new_config
}

# Validation check
check "assume_role_policy_configuration" {
  assert {
    condition     = local.has_valid_config
    error_message = "Either 'assume_role_policy' OR both 'principal_type' and 'principal_identifiers' must be provided"
  }

  assert {
    condition     = !local.has_legacy_policy || !local.has_new_config
    error_message = "Cannot provide both 'assume_role_policy' and 'principal_type/principal_identifiers'. Use one approach or the other"
  }
}
