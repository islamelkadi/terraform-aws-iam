# Terraform AWS IAM Policy Module

Production-ready AWS IAM Policy module for creating and attaching custom IAM policies to users, groups, and roles. Supports policy document management with automatic attachment.

## Table of Contents

- [Features](#features)
- [Usage Example](#usage-example)
- [Requirements](#requirements)

## Features

- **Policy Creation**: Create custom IAM policies from JSON documents
- **Automatic Attachment**: Attach policies to users, groups, and roles
- **Path Organization**: Support for IAM path hierarchy
- **Consistent Naming**: Integration with metadata module for standardized resource naming



## Security

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| Least privilege | Enforced | Enforced | Enforced |
| No wildcard resources | Recommended | Required | Required |
| Policy scope restrictions | Recommended | Required | Required |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.
## Security

#
## Usage Example

```hcl
data "aws_iam_policy_document" "s3_read" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.bucket.arn,
      "${module.bucket.arn}/*"
    ]
  }
}

module "s3_read_policy" {
  source = "github.com/islamelkadi/terraform-aws-iam//modules/policy"
  
  namespace   = "example"
  environment = "prod"
  name        = "s3-read-access"
  region      = "us-east-1"
  
  description     = "Read-only access to corporate actions S3 bucket"
  policy_document = data.aws_iam_policy_document.s3_read.json
  
  attach_to_roles = [
    module.lambda_role.role_name
  ]
  
  tags = {
    Purpose = "DataAccess"
  }
}
```


<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
# Basic IAM Policy Example

module "corporate_actions_policy" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description
  path        = var.path

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.region}:123456789012:table/corporate-actions",
          "arn:aws:dynamodb:${var.region}:123456789012:table/corporate-actions/index/*"
        ]
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::corporate-actions-raw-feeds",
          "arn:aws:s3:::corporate-actions-raw-feeds/*"
        ]
      }
    ]
  })

  attach_to_roles = var.attach_to_roles

  tags = var.tags
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_group_policy_attachment.groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_to_groups"></a> [attach\_to\_groups](#input\_attach\_to\_groups) | List of IAM group names to attach this policy to | `list(string)` | `[]` | no |
| <a name="input_attach_to_roles"></a> [attach\_to\_roles](#input\_attach\_to\_roles) | List of IAM role names to attach this policy to | `list(string)` | `[]` | no |
| <a name="input_attach_to_users"></a> [attach\_to\_users](#input\_attach\_to\_users) | List of IAM user names to attach this policy to | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the IAM policy | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM policy | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path in which to create the policy | `string` | `"/"` | no |
| <a name="input_policy_document"></a> [policy\_document](#input\_policy\_document) | JSON-encoded IAM policy document | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attached_groups"></a> [attached\_groups](#output\_attached\_groups) | List of group names this policy is attached to |
| <a name="output_attached_roles"></a> [attached\_roles](#output\_attached\_roles) | List of role names this policy is attached to |
| <a name="output_attached_users"></a> [attached\_users](#output\_attached\_users) | List of user names this policy is attached to |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the IAM policy |
| <a name="output_policy_document"></a> [policy\_document](#output\_policy\_document) | Policy document of the IAM policy |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | ID of the IAM policy |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | Name of the IAM policy |
| <a name="output_policy_path"></a> [policy\_path](#output\_policy\_path) | Path of the IAM policy |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the IAM policy |

## Example

See [example/](example/) for a complete working example with all features.

