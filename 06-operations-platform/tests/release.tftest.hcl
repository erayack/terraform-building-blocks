run "release_name_contains_service" {
  command = plan

  assert {
    condition     = startswith(output.release_name, "payments-")
    error_message = "release_name must start with the service name."
  }
}
