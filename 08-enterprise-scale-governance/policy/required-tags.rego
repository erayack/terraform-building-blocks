package terraform.policy

# Teaching policy: every created resource that exposes a `tags` attribute in
# the plan must include the standard ownership tags. Resources without `tags`
# are ignored here. Production policies need provider-specific edge-case handling.

required_tags := {"Project", "Environment", "Owner", "CostCenter"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.change.actions[_] == "create"

  tags := object.get(resource.change.after, "tags", null)
  tags != null

  missing := required_tags - {tag | tags[tag]}
  count(missing) > 0

  msg := sprintf("%s is missing required tags: %v", [resource.address, missing])
}
