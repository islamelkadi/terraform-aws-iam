# Terraform AWS IAM Module

Reusable Terraform module for AWS IAM roles and policies.

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.

## Submodules

| Submodule | Description |
|-----------|-------------|
| [role](modules/role/) | IAM roles with assume role policies, managed and inline policies |
| [policy](modules/policy/) | Standalone IAM policies with optional attachments |

## Usage

```hcl
module "lambda_role" {
  source = "path/to/terraform-aws-iam/modules/role"

  namespace   = "example"
  environment = "prod"
  name        = "lambda-execution"
  region      = "us-east-1"

  description           = "Lambda execution role"
  principal_type        = "Service"
  principal_identifiers = ["lambda.amazonaws.com"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  tags = var.tags
}
```

## Security Controls

Implements controls for FSBP, CIS, NIST 800-53/171, and PCI DSS v4.0:

- Least privilege IAM policies
- No wildcard resources (configurable)
- Service roles with proper assume role policies
- Path-based organization
- Security control overrides with audit justification

## Module Structure

```
terraform-aws-iam/
├── modules/
│   ├── role/
│   │   ├── example/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── params/input.tfvars
│   │   └── ...
│   └── policy/
│       └── ...
└── README.md
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.3 |
| aws | >= 6.34 |

## Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles){:target="_blank"} module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| Least privilege | Enforced | Enforced | Enforced |
| No wildcard resources | Recommended | Required | Required |
| Service roles | Required | Required | Required |
| MFA for human access | Optional | Required | Required |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.

## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->


## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
