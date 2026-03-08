## [1.0.1](https://github.com/islamelkadi/terraform-aws-iam/compare/v1.0.0...v1.0.1) (2026-03-08)


### Bug Fixes

* add CKV_TF_1 suppression for external module metadata ([f01cf5e](https://github.com/islamelkadi/terraform-aws-iam/commit/f01cf5e518ee938d3e7ea6408a444783c0df0a04))
* add skip-path for .external_modules in Checkov config ([341dabf](https://github.com/islamelkadi/terraform-aws-iam/commit/341dabf1a2b909177b29c8fb017ea51edb4fe532))
* address Checkov security findings ([218c4f5](https://github.com/islamelkadi/terraform-aws-iam/commit/218c4f5d4f7fd503a7b4eb50be0be8840bfe815a))
* correct .checkov.yaml format to use simple list instead of id/comment dict ([84dbfeb](https://github.com/islamelkadi/terraform-aws-iam/commit/84dbfebe706551ddb159e965f8bac33c9d7d4c38))
* remove skip-path from .checkov.yaml, rely on workflow-level skip_path ([f0e9044](https://github.com/islamelkadi/terraform-aws-iam/commit/f0e9044a687e1928a7ba27ddfb07cb2616734842))
* update workflow path reference to terraform-security.yaml ([bf54e41](https://github.com/islamelkadi/terraform-aws-iam/commit/bf54e41d1dc700eab6f764c31d843046eeb86de9))

## 1.0.0 (2026-03-07)


### ⚠ BREAKING CHANGES

* First publish - IAM Terraform module

### Features

* First publish - IAM Terraform module ([c821116](https://github.com/islamelkadi/terraform-aws-iam/commit/c82111610506729b9bc07c7b474492504036ede1))
