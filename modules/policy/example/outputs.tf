# Example Outputs

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = module.corporate_actions_policy.policy_arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = module.corporate_actions_policy.policy_name
}
