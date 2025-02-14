---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: ir-04
---

# IR-4: Incident Handling

## Implementation Status: Implemented

## Control Statement

The organization:
a. Implements an incident handling capability
b. Coordinates incident handling activities
c. Tracks and documents incidents

## Implementation

### Incident Handling Process

1. Detection & Analysis:
   - AWS Security Hub
   - Amazon GuardDuty
   - CloudWatch Alarms
   - CloudTrail Events

2. Automated Response:
   - EventBridge Rules
   - Lambda Functions
   - Systems Manager Automation
   - Security Hub Workflows

3. Containment Strategies:
   - Network Isolation
   - Resource Termination
   - Access Revocation
   - Snapshot Creation

4. Evidence Collection:
   - CloudWatch Logs
   - CloudTrail Records
   - VPC Flow Logs
   - Security Hub Findings

### Evidence

```sql
select
  severity_label,
  workflow_status,
  count(*) as incident_count,
  round(avg(extract(epoch from updated_at - created_at)/3600), 2) as avg_hours_to_resolve
from
  aws_securityhub_finding
where
  created_at > now() - interval '90 days'
group by
  severity_label,
  workflow_status
order by
  severity_label desc;
