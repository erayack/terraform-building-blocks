package terraform.policy

# Teaching policy: deny unsupported `aws_region` variable values when that
# variable exists in the Terraform plan JSON. Real implementations often read
# region from CI context, provider config, account metadata, or platform inventory.

allowed_regions := {"us-east-1", "us-west-2", "eu-west-1"}

deny[msg] {
  region := input.variables.aws_region.value
  not allowed_regions[region]

  msg := sprintf("region %s is not approved for this platform", [region])
}
