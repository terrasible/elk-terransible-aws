# Set common variables for the account. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  remote_bucket_name = "elk-poc-terraform-state"
  remote_bucket_key  = "terraform/state"
  region             = "ap-southeast-1"
  zones              = ["ap-southeast-1a", "ap-southeast-1b"]
}