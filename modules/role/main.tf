# IAM Role Module
# Creates AWS IAM role with least privilege principles

# Generate assume role policy document if not provided
data "aws_iam_policy_document" "assume_role" {
  count = var.assume_role_policy == null ? 1 : 0

  statement {
    effect  = "Allow"
    actions = var.assume_role_actions

    principals {
      type        = var.principal_type
      identifiers = var.principal_identifiers
    }

    dynamic "condition" {
      for_each = var.assume_role_conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name                  = local.role_name
  description           = var.description != "" ? var.description : "IAM role for ${local.role_name}"
  assume_role_policy    = var.assume_role_policy != null ? var.assume_role_policy : data.aws_iam_policy_document.assume_role[0].json
  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policies
  path                  = var.path
  permissions_boundary  = var.permissions_boundary

  tags = local.tags
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Attach custom policies
resource "aws_iam_role_policy_attachment" "custom" {
  for_each = var.custom_policy_arns

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Attach policies from policy modules
resource "aws_iam_role_policy_attachment" "policy_modules" {
  for_each = { for idx, policy in var.policy_attachments : idx => policy }

  role       = aws_iam_role.this.name
  policy_arn = each.value.policy_arn
}

# Create inline policies
resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}
