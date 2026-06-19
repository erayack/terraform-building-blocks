# Recovery Plan Example

This is a teaching template, not a complete disaster recovery plan.

## Service

- Service: payments-api
- Owner: payments-platform@example.com
- Environment: prod

## Objectives

- RTO: 2 hours
- RPO: 15 minutes

## Terraform role

Terraform can recreate the infrastructure shape:

- network attachments,
- security groups,
- compute resources,
- load balancer configuration,
- monitoring alarms.

Terraform does not restore application data by itself.

## Data recovery

Data restore depends on:

- backup frequency,
- replication mode,
- database engine,
- restore testing,
- application consistency checks.

## Manual checks

Before declaring recovery complete:

1. Confirm database restore point.
2. Run application health checks.
3. Verify DNS or traffic failover.
4. Confirm monitoring and alerts are active.
5. Record the incident timeline.

## Practice schedule

Run a recovery exercise at least twice per year.
