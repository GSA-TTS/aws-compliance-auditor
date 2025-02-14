---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: ir-06
---

# IR-6: Incident Reporting

## Implementation Status: Implemented

## Control Statement

The organization:
a. Requires personnel to report suspected incidents
b. Reports security incidents to appropriate authorities

## Implementation

### Incident Reporting Framework

1. Automated Detection:
   - Security Hub integration
   - GuardDuty findings
   - CloudWatch alerts
   - Config rule violations

2. Reporting Channels:
   - SNS notifications
   - Slack integrations
   - Email alerts
   - Ticketing systems

3. Reporting Timeline:
   - Critical incidents: 1 hour
   - High severity: 4 hours
   - Medium severity: 24 hours
   - Low severity: 72 hours

4. Documentation Requirements:
   - Incident details
   - Impact assessment
   - Response actions
   - Resolution status

### AWS Implementation

1. Detection Methods:
   - GuardDuty findings
   - Security Hub alerts
   - CloudWatch alarms
   - CloudTrail events

2. Automated Reporting:
   - EventBridge rules
   - SNS notifications
   - Lambda functions
   - Incident Manager

3. Response Tracking:
   - Security Hub workflows
   - Incident tickets
   - Resolution status
   - Timeline tracking

4. Compliance Integration:
   - FedRAMP requirements
   - NIST standards
   - Agency policies
   - Audit trails

### Supporting Evidence

```sql
select
  severity_label,
  count(*) as incident_count,
  avg(extract(epoch from updated_at - created_at)/3600)::numeric(10,2) as avg_resolution_hours
from
  aws_securityhub_finding
where
  workflow_status = 'RESOLVED'
  and created_at > now() - interval '30 days'
group by
  severity_label;
```
