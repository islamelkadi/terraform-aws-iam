namespace   = "example"
environment = "dev"
name        = "corporate-actions-access"
region      = "us-east-1"

description = "Access policy for Corporate Actions Orchestrator"
path        = "/corporate-actions/"

attach_to_roles = ["example-lambda-role"]

tags = {
  Example = "IAM_POLICY"
}
