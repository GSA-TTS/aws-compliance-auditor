---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: ra-03
---

# RA-3: Risk Assessment

## Implementation Status: Implemented

## Control Statement

The organization:
a. Conducts risk assessment
b. Documents risk assessment results
c. Reviews risk assessment results
d. Disseminates risk assessment results
e. Updates risk assessment

## Implementation

### Risk Assessment Process

1. Assessment Methods:
   - Automated vulnerability scanning
   - Threat intelligence analysis
   - Security control assessment
   - Configuration compliance checks

2. Documentation Requirements:
   - Findings and vulnerabilities
   - Risk levels and impacts
   - Mitigation recommendations
   - Remediation timelines

3. Review Procedures:
   - Monthly security reviews
   - Quarterly risk assessments
   - Annual comprehensive analysis
   - Continuous monitoring alerts

4. Communication:
   - Security status reports
   - Risk assessment findings
   - Mitigation strategies
   - Stakeholder notifications

### AWS Implementation

1. Automated Assessment Tools:
   - AWS Security Hub for centralized security findings
   - Amazon Inspector for vulnerability assessments
   - Amazon GuardDuty for threat detection
   - AWS Config for configuration assessment

2. Risk Scoring:
   - Severity based on CVSS scores
   - Business impact analysis
   - Data sensitivity levels
   - System criticality

3. Continuous Monitoring:
   - Real-time security alerts
   - Daily compliance checks
   - Weekly vulnerability scans
   - Monthly risk reviews

4. Documentation and Reporting:
   - Automated finding collection
   - Risk assessment dashboards
   - Compliance status tracking
   - Remediation workflows

### Implementation Evidence

```sql
select 
  count(*) as total_findings,
  sum(case when severity_label = 'CRITICAL' then 1 else 0 end) as critical,
  sum(case when severity_label = 'HIGH' then 1 else 0 end) as high,
  sum(case when workflow_status = 'RESOLVED' then 1 else 0 end) as resolved
from
  aws_securityhub_finding
where 
  record_state = 'ACTIVE';
