# Basic IAM Role Example

This example creates a Lambda execution role with VPC access and CloudWatch Logs permissions.

## Usage

```bash
terraform init
terraform plan -var-file=params/input.tfvars
terraform apply -var-file=params/input.tfvars
```

## What This Example Creates

- IAM role with Lambda service principal
- VPC access managed policy attachment
- Inline policy for CloudWatch Logs

## Clean Up

```bash
terraform destroy -var-file=params/input.tfvars
```
