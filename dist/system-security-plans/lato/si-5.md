---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: si-05
---

# SI-5: Security Alerts and Advisories

## Implementation Status: Implemented

## Control Statement

The organization:
a. Receives security alerts and advisories
b. Generates internal security alerts
c. Disseminates alerts to appropriate personnel
d. Takes appropriate actions in response

## Implementation

### Alert Management

1. Information Sources:
   - AWS Security Bulletins 
   - Security Hub Findings
   - GuardDuty Alerts
   - Trusted Advisories

2. Alert Processing:
   - Automated collection
   - Severity assessment
   - Impact analysis
   - Distribution rules

3. Response Actions:
   - Immediate mitigation
   - Scheduled patches
   - Configuration updates
   - Policy adjustments

4. Documentation:
   - Alert tracking
   - Response records
   - Effectiveness metrics
   - Lessons learned

### AWS Implementation

1. Alert Sources:
   - AWS Security Bulletins
   - GuardDuty Findings
   - SecurityHub Alerts
   - Inspector Assessments
   - Config Rule Violations

2. Processing Pipeline:
   - Event collection
   - Risk assessment
   - Priority assignment
   - Alert correlation

3. Distribution Methods:
   - SNS notifications
   - Email alerts
   - Slack integration
   - JIRA tickets

4. Response Framework:
   - SLA-based responses
   - Automated remediation
   - Manual intervention
   - Incident tracking

### Evidence

```sql
select 
  count(*) as total_alerts,
  severity_label,
  workflow_status
from 
  aws_securityhub_finding
where 
  created_at > now() - interval '7 days'
group by 
  severity_label, workflow_status
order by 
  severity_label;
