variable "aws_region" {
  description = "AWS region for the provider (IAM is global; used for provider configuration)."
  type        = string
  default     = "us-east-1"
}

variable "role_name" {
  description = "Name of the IAM role assumed by GitHub Actions for Packer builds."
  type        = string
  default     = "github-actions-packer"
}

variable "github_organization" {
  description = "GitHub organization or user that owns the repository allowed to assume this role."
  type        = string
  default     = "benjamin-lykins"
}

variable "github_repository" {
  description = "GitHub repository name (without org) allowed to assume this role, e.g. my-packer-images."
  type        = string
}

variable "oidc_subject_claim" {
  description = "Suffix of the OIDC sub claim after repo:org/repo:. Use * for any ref/environment, or e.g. ref:refs/heads/main or environment:prod."
  type        = string
  default     = "*"
}

variable "create_oidc_provider" {
  description = "Create the GitHub Actions OIDC identity provider. Set true only if one does not already exist in this AWS account (AWS allows one per URL)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to IAM resources that support tagging."
  type        = map(string)
  default     = {}
}
