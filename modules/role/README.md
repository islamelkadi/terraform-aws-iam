# Terraform AWS IAM Role Module

Production-ready AWS IAM Role module with comprehensive security controls, policy attachment management, and least privilege enforcement. Supports managed policies, inline policies, and custom policy attachments with security validations.

## Table of Contents

- [Security](#security)
- [Features](#features)
- [Usage Examples](#usage-examples)
- [Requirements](#requirements)
- [Examples](#examples)

## Features

- **Flexible Policy Attachment**: Support for managed, inline, and custom policies
- **Permissions Boundary**: Optional permissions boundary for delegated administration
- **Session Duration Control**: Configurable maximum session duration (1-12 hours)
- **Force Detach**: Optional force detachment of policies before deletion
- **Custom Path**: Support for IAM path organization
- **Consistent Naming**: Integration with metadata module for standardized resource naming
- **Security Validations**: Least privilege and wildcard resource checks

## Security

### Security Controls

This module implements security controls based on the metadata module's security policy. Controls can be selectively overridden with documented business justification.

### Available Security Control Overrides

| Override Flag | Control | Default | Common Use Case |
|--------------|---------|---------|-----------------|
| `disable_least_privilege_check` | Least Privilege Validation | `false` | Service roles requiring broad permissions |
| `disable_wildcard_check` | Wildcard Resource Prohibition | `false` | Cross-account or dynamic resource access patterns |

### Security Control Architecture

**Two-Layer Design:**
1. **Metadata Module** (Policy Layer): Defines security requirements based on environment
2. **IAM Role Module** (Enforcement Layer): Validates configuration against policy

**Override Pattern:**
```hcl
security_control_overrides = {
  disable_wildcard_check = true
  justification = "CloudWatch Logs service role requires wildcard for log stream creation"
}
```

### Best Practices

1. **Least Privilege**: Always use specific resource ARNs instead of wildcards
2. **Policy Boundaries**: Use permissions boundaries for delegated administration
3. **Session Duration**: Limit max session duration to minimum required
4. **Audit Trail**: All overrides require `justification` field for compliance
5. **Review Cycle**: Quarterly review of all IAM roles and policies

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| Least privilege | Enforced | Enforced | Enforced |
| No wildcard resources | Recommended | Required | Required |
| Service roles | Required | Required | Required |
| Session duration limits | Relaxed | Standard | Strict |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.
## Usage Examples

### Example 1: Basic Lambda Execution Role (Simplified)

```hcl
module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata"
  
  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions"
  region      = "us-east-1"
}

module "lambda_role" {
  source = "github.com/islamelkadi/terraform-aws-iam//modules/role"
  
  namespace   = module.metadata.namespace
  environment = module.metadata.environment
  name        = "event-normalizer-lambda"
  region      = module.metadata.region
  
  description = "Execution role for event normalizer Lambda function"
  
  # Simplified assume role policy configuration
  principal_type        = "Service"
  principal_identifiers = ["lambda.amazonaws.com"]
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  
  inline_policies = {
    "dynamodb-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = module.events_table.arn
      }]
    })
  }
  
  security_controls = module.metadata.security_controls
  
  tags = module.metadata.tags
}
```

### Example 2: Step Functions Execution Role (Simplified)

```hcl
module "sfn_role" {
  source = "github.com/islamelkadi/terraform-aws-iam//modules/role"
  
  namespace   = "example"
  environment = "prod"
  name        = "orchestrator-sfn"
  region      = "us-east-1"
  
  description = "Execution role for corporate actions orchestrator"
  
  # Simplified assume role policy configuration
  principal_type        = "Service"
  principal_identifiers = ["states.amazonaws.com"]
  
  inline_policies = {
    "lambda-invoke" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = [
          module.normalizer_lambda.arn,
          module.scanner_lambda.arn,
          module.notifier_lambda.arn
        ]
      }]
    })
    "cloudwatch-logs" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }]
    })
  }
  
  security_controls = module.metadata.security_controls
  
  # Override for CloudWatch Logs wildcard requirement
  security_control_overrides = {
    disable_wildcard_check = true
    justification = "CloudWatch Logs service integration requires wildcard for log delivery"
  }
  
  tags = module.metadata.tags
}
```

### Example 3: Cross-Account Access Role with Conditions (Simplified)

```hcl
module "cross_account_role" {
  source = "github.com/islamelkadi/terraform-aws-iam//modules/role"
  
  namespace   = "example"
  environment = "prod"
  name        = "cross-account-reader"
  region      = "us-east-1"
  
  description = "Cross-account read-only access role"
  
  # Simplified assume role policy with conditions
  principal_type        = "AWS"
  principal_identifiers = ["arn:aws:iam::123456789012:root"]
  
  assume_role_conditions = [
    {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["unique-external-id"]
    }
  ]
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
  
  max_session_duration = 3600  # 1 hour
  
  security_controls = module.metadata.security_controls
  
  tags = merge(
    module.metadata.tags,
    {
      AccessType = "CrossAccount"
      ExternalId = "unique-external-id"
    }
  )
}
```

### Example 4: Bedrock AgentCore Runtime Role (Simplified)

```hcl
module "agentcore_role" {
  source = "github.com/islamelkadi/terraform-aws-iam//modules/role"
  
  namespace   = "example"
  environment = "prod"
  name        = "agentcore-runtime"
  region      = "us-east-1"
  
  description = "Execution role for Bedrock AgentCore Runtime"
  
  # Simplified assume role policy configuration
  principal_type        = "Service"
  principal_identifiers = ["bedrock.amazonaws.com"]
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  
  inline_policies = {
    "bedrock-invoke" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:InvokeCodeInterpreter"
        ]
        Resource = [
          "arn:aws:bedrock:ca-central-1::foundation-model/anthropic.claude-3-opus-20240229-v1:0",
          "arn:aws:bedrock:ca-central-1:*:code-interpreter/*"
        ]
      }]
    })
  }
  
  security_controls = module.metadata.security_controls
  
  tags = module.metadata.tags
}
```

### Example 5: Legacy Usage (Backward Compatible)

For existing code that uses the old pattern, the module remains fully backward compatible:

```hcl
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

module "lambda_role" {
  source = "github.com/islamelkadi/terraform-aws-iam//modules/role"
  
  namespace   = "example"
  environment = "prod"
  name        = "legacy-lambda"
  region      = "us-east-1"
  
  description        = "Legacy usage pattern"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  
  # ... rest of configuration
}
```

<!-- BEGIN_TF_DOCS -->

## Usage

```hcl
# Basic IAM Role Example

module "lambda_role" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description

  principal_type        = var.principal_type
  principal_identifiers = var.principal_identifiers

  managed_policy_arns = var.managed_policy_arns

  inline_policies = {
    "cloudwatch-logs" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:*:log-group:/aws/lambda/${var.namespace}-${var.environment}-${var.name}*"
      }]
    })
  }

  max_session_duration = var.max_session_duration

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
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.policy_modules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_actions"></a> [assume\_role\_actions](#input\_assume\_role\_actions) | List of actions allowed in the assume role policy | `list(string)` | <pre>[<br/>  "sts:AssumeRole"<br/>]</pre> | no |
| <a name="input_assume_role_conditions"></a> [assume\_role\_conditions](#input\_assume\_role\_conditions) | Optional conditions for the assume role policy | <pre>list(object({<br/>    test     = string<br/>    variable = string<br/>    values   = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | JSON-encoded assume role policy document. If not provided, will be generated from principal\_type and principal\_identifiers | `string` | `null` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_custom_policy_arns"></a> [custom\_policy\_arns](#input\_custom\_policy\_arns) | Map of custom policy ARNs to attach to the role (key = policy name, value = policy ARN) | `map(string)` | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the IAM role | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Whether to force detaching any policies the role has before destroying it | `bool` | `false` | no |
| <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies) | Map of inline policy names to policy documents (JSON) | `map(string)` | `{}` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of AWS managed policy ARNs to attach to the role | `list(string)` | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration in seconds (1 hour to 12 hours) | `number` | `3600` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM role | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path in which to create the role | `string` | `"/"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the role | `string` | `null` | no |
| <a name="input_policy_attachments"></a> [policy\_attachments](#input\_policy\_attachments) | List of policy module outputs to attach to the role. Each item should be a policy module output containing policy\_arn | <pre>list(object({<br/>    policy_arn = string<br/>  }))</pre> | `[]` | no |
| <a name="input_principal_identifiers"></a> [principal\_identifiers](#input\_principal\_identifiers) | List of principal identifiers (e.g., ['lambda.amazonaws.com'] for Service, ['arn:aws:iam::123456789012:root'] for AWS). Required if assume\_role\_policy is not provided | `list(string)` | `null` | no |
| <a name="input_principal_type"></a> [principal\_type](#input\_principal\_type) | Type of principal that can assume this role (Service, AWS, Federated). Required if assume\_role\_policy is not provided | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls with documented justification | <pre>object({<br/>    disable_least_privilege_check = optional(bool, false)<br/>    disable_wildcard_check        = optional(bool, false)<br/>    justification                 = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_least_privilege_check": false,<br/>  "disable_wildcard_check": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>    data_protection = object({<br/>      require_versioning  = bool<br/>      require_mfa_delete  = bool<br/>      require_backup      = bool<br/>      require_lifecycle   = bool<br/>      block_public_access = bool<br/>      require_replication = bool<br/>    })<br/>    iam = optional(object({<br/>      require_least_privilege     = bool<br/>      prohibit_wildcard_resources = bool<br/>      require_mfa                 = bool<br/>      max_session_duration        = number<br/>      }), {<br/>      require_least_privilege     = false<br/>      prohibit_wildcard_resources = false<br/>      require_mfa                 = false<br/>      max_session_duration        = 43200<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | ID of the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role |
| <a name="output_role_unique_id"></a> [role\_unique\_id](#output\_role\_unique\_id) | Unique ID of the IAM role |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the IAM role |

## Examples

See [example/](example/) for a complete working example.

