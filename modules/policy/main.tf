# IAM Policy Module
# Creates AWS IAM policies with security best practices

# IAM Policy
resource "aws_iam_policy" "this" {
  name        = local.policy_name
  description = var.description != "" ? var.description : "IAM policy ${local.policy_name}"
  path        = var.path
  policy      = var.policy_document

  tags = local.tags
}

# Optional policy attachments to roles
resource "aws_iam_role_policy_attachment" "roles" {
  for_each = toset(var.attach_to_roles)

  role       = each.value
  policy_arn = aws_iam_policy.this.arn
}

# Optional policy attachments to users
resource "aws_iam_user_policy_attachment" "users" {
  for_each = toset(var.attach_to_users)

  user       = each.value
  policy_arn = aws_iam_policy.this.arn
}

# Optional policy attachments to groups
resource "aws_iam_group_policy_attachment" "groups" {
  for_each = toset(var.attach_to_groups)

  group      = each.value
  policy_arn = aws_iam_policy.this.arn
}
