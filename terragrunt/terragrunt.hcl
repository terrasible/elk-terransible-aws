# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  region             = local.region_vars.locals.region
  remote_bucket_name = local.region_vars.locals.remote_bucket_name
  remote_bucket_key  = local.region_vars.locals.remote_bucket_key
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.region}"
}
EOF
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    region         = "${local.region}"
    bucket         = "${local.remote_bucket_name}"
    key            = "${local.remote_bucket_key}/${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "${local.remote_bucket_name}"
    encrypt        = true
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = ">= 3.22.0"
  }
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.region_vars.locals,
  local.environment_vars.locals,
)