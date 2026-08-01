output "role_arn" {
  description = "ARN of the IAM role for GitHub Actions to assume (use with aws-actions/configure-aws-credentials)."
  value       = aws_iam_role.packer.arn
}

output "role_name" {
  description = "Name of the Packer IAM role."
  value       = aws_iam_role.packer.name
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC identity provider used by the role trust policy."
  value       = local.oidc_provider_arn
}
