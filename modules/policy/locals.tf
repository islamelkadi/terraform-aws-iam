# Local values for naming and tagging

locals {
  # Use metadata module for naming
  policy_name = module.metadata.resource_prefix

  # Create tags with metadata information
  tags = merge(
    module.metadata.security_tags,
    var.tags,
    {
      Name   = module.metadata.resource_prefix
      Module = "terraform-aws-iam-policy"
    }
  )
}
