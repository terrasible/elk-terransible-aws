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
  ssh_machine_ip     = local.environment_vars.locals.ssh_machine_ip
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-security-group.git//?ref=v3.17.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/${local.region}/${local.env}/vpc"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name   = "${local.common_name_prefix}-asg-sg"
  vpc_id = "${dependency.vpc.outputs.vpc_id}"

  # Allow OpenVPN client CIDR
  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["elasticsearch-rest-tcp", "elasticsearch-java-tcp", "all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "${local.ssh_machine_ip}"
      description = "ssh to server from local PC"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = {
    ManagedBy   = "${local.common_name_prefix}"
    CreatedBY   = "Terraform"
    Environment = "${local.env}"
  }
}