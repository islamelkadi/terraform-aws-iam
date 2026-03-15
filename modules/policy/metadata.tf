# Metadata module for consistent naming and tagging
module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata?ref=v1.1.1"

  namespace     = var.namespace
  project_name  = var.name
  environment   = var.environment
  resource_type = "iam-policy"
  region        = var.region
}
