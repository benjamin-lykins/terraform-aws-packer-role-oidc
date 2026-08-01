# terraform-aws-packer-role-oidc

HCP Terraform **no-code ready** module that creates an AWS IAM role for [Packer](https://www.packer.io/) AMI builds, assumed by GitHub Actions via [OpenID Connect](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws) (no long-lived AWS keys).

Trust is scoped to repositories under **`benjamin-lykins`** by default.

## What it creates

| Resource | Description |
|----------|-------------|
| IAM OIDC provider (optional) | `token.actions.githubusercontent.com` — create only if missing in the account |
| IAM role | Trusted by GitHub Actions OIDC for a specific repo |
| Inline IAM policy | Packer `amazon-ebs` EC2 permissions + temporary instance profile / `PassRole` |

## No-code usage (HCP Terraform)

1. Publish this module to your HCP Terraform private registry.
2. Enable **No-code provisioning** for the module version.
3. Ensure the target project has AWS credentials (recommended: project-scoped variable set with `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, or dynamic credentials).
4. Provision from the UI and set:

| Variable | Required | Default | Notes |
|----------|----------|---------|-------|
| `github_repository` | yes | — | Repo name only, e.g. `my-packer-images` |
| `aws_region` | no | `us-east-1` | Provider region |
| `role_name` | no | `github-actions-packer` | IAM role name |
| `github_organization` | no | `benjamin-lykins` | GitHub owner |
| `oidc_subject_claim` | no | `*` | e.g. `ref:refs/heads/main` or `environment:prod` |
| `create_oidc_provider` | no | `true` | Set `false` if the GitHub OIDC provider already exists in the account |
| `tags` | no | `{}` | Resource tags |

Copy the `role_arn` output into your workflow.

## GitHub Actions example

```yaml
name: Packer build

on:
  push:
    branches: [main]

permissions:
  id-token: write   # Required to request the OIDC JWT
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT_ID:role/github-actions-packer
          aws-region: us-east-1
          role-session-name: packer-github-actions

      - name: Build AMI
        run: |
          packer init .
          packer build .
```

Replace `role-to-assume` with the module’s `role_arn` output.

## Trust policy shape

```text
repo:${github_organization}/${github_repository}:${oidc_subject_claim}
```

Examples:

- `repo:benjamin-lykins/my-packer-images:*` (default)
- `repo:benjamin-lykins/my-packer-images:ref:refs/heads/main`
- `repo:benjamin-lykins/my-packer-images:environment:prod`

Audience is always `sts.amazonaws.com`.

## OIDC provider note

AWS allows **one** IAM OIDC provider per URL per account. The default `create_oidc_provider = true` creates it on first use. If the provider already exists (e.g. from another workspace), set `create_oidc_provider = false` so the module looks it up by URL instead.

## Permissions

The role includes the [minimal Packer Amazon plugin EC2 actions](https://developer.hashicorp.com/packer/integrations/hashicorp/amazon), plus common extras (`DescribeVpcs`, spot/fleet describe/create) and IAM actions for `PassRole` and temporary instance profiles.

Encrypted AMIs that use a customer-managed KMS key may need additional KMS grants on the key policy — not managed by this module.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | ~> 6.0 |

This module declares an inline `provider "aws"` block so it can be used with HCP Terraform no-code provisioning. Prefer variable sets for credentials rather than hardcoding them in the module.
