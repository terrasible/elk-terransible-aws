locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env                = local.environment_vars.locals.environment
  region             = local.region_vars.locals.region
  zones              = local.region_vars.locals.zones
  common_name_prefix = local.environment_vars.locals.common_name_prefix
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git//?ref=v2.66.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name = "${local.common_name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  # The zones we will be using will only be ap-southeast-1a, ap-southeast-1b
  azs             = "${local.zones}"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  # enable nat & mappping of Public IP
  map_public_ip_on_launch              = true
  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = {
    Environment = "${local.env}"
    CreatedBY   = "Terraform"
    ManagedBY   = "${local.common_name_prefix}"
  }
}