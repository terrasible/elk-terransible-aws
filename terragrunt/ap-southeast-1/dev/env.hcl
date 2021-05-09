# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment        = "dev"
  common_name_prefix = "elk-poc"
  ssh_machine_ip     = "123.201.116.22/32"
  key_name           = "elk-poc"
}