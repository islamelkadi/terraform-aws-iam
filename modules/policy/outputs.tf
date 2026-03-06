# IAM Policy Module Outputs

output "policy_id" {
  description = "ID of the IAM policy"
  value       = aws_iam_policy.this.id
}

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = aws_iam_policy.this.arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = aws_iam_policy.this.name
}

output "policy_path" {
  description = "Path of the IAM policy"
  value       = aws_iam_policy.this.path
}

output "policy_document" {
  description = "Policy document of the IAM policy"
  value       = aws_iam_policy.this.policy
}

output "tags" {
  description = "Tags applied to the IAM policy"
  value       = aws_iam_policy.this.tags
}

output "attached_roles" {
  description = "List of role names this policy is attached to"
  value       = var.attach_to_roles
}

output "attached_users" {
  description = "List of user names this policy is attached to"
  value       = var.attach_to_users
}

output "attached_groups" {
  description = "List of group names this policy is attached to"
  value       = var.attach_to_groups
}
