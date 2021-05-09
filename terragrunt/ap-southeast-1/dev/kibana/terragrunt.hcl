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
  source = "git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git"
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "subnet" {
  config_path = "${get_parent_terragrunt_dir()}/${local.region}/${local.env}/vpc"
}

dependency "sg" {
  config_path = "${get_parent_terragrunt_dir()}/${local.region}/${local.env}/security-group/ec2"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name = "kibana"

  ami                         = "ami-02f26adf094f51167"
  instance_count              = 1
  instance_type               = "t2.micro"
  subnet_ids                  = dependency.subnet.outputs.public_subnets
  associate_public_ip_address = true
  key_name                    = local.environment_vars.locals.key_name
  monitoring                  = true
  user_data                   = file("${get_parent_terragrunt_dir()}/${local.region}/${local.env}/kibana/metadata.sh")
  vpc_security_group_ids = [
    dependency.sg.outputs.this_security_group_id
  ]
  tags = {
    Environment = "${local.env}"
    CreatedBy   = "Terraform"
    ManagedBy   = "${local.common_name_prefix}"
  }
}
