# Metadata module for consistent naming and tagging
module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata"

  namespace     = var.namespace
  project_name  = var.name
  environment   = var.environment
  resource_type = "iam-role"
  region        = var.region
}
