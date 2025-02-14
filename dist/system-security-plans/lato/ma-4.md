---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: ma-04
---

# MA-4: Nonlocal Maintenance

## Implementation Status: Implemented

## Control Statement

The organization:
a. Approves nonlocal maintenance
b. Monitors nonlocal maintenance
c. Documents nonlocal maintenance
d. Terminates sessions when completed

## Implementation

### Remote Maintenance Controls

1. Access Management:
   - Strong authentication
   - Session monitoring
   - Access logging
   - Connection encryption

2. Security Requirements:
   - MFA enforcement
   - Tool restrictions
   - Network controls
   - Session timeouts

3. Documentation:
   - Access approvals
   - Activity logs
   - Security reviews
   - Compliance reports

4. Monitoring:
   - Real-time alerts
   - Session recording
   - Access analysis
   - Anomaly detection

### AWS Evidence

```sql
select
  user_name,
  password_last_used,
  mfa_active,
  access_key_1_last_used_date
from
  aws_iam_user
where
  user_name like '%maintenance%'
  and password_enabled = true;
```

### AWS Implementation

1. Remote Access Controls:
   - Session Manager for secure shell access
   - AWS Systems Manager for remote management
   - CloudWatch logs for activity monitoring
   - IAM roles for access control

2. Security Requirements:
   - Multi-factor authentication
   - Encrypted connections
   - Session recording
   - Access reviews

3. Monitoring Controls:
   - Real-time activity logging
   - Session tracking
   - Access analysis
   - Alert configuration

4. Documentation:
   - Access requests
   - Activity reports
   - Security reviews
   - Compliance checks
```
