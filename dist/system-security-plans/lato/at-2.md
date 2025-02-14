---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: at-02
---

# AT-2: Security Awareness Training

## Implementation Status: Implemented

## Control Statement

The organization provides basic security awareness training to all users:
a. As part of initial access
b. When required by system changes
c. Annually thereafter

## Implementation

### Training Program

1. Initial Training:
   - Security fundamentals
   - Access management
   - Data handling
   - Incident reporting
   - Compliance requirements

2. Ongoing Training:
   - Annual refreshers
   - Security updates
   - Threat awareness
   - Policy changes

3. Special Focus Areas:
   - Social engineering
   - Phishing awareness
   - Password management
   - Mobile device security

4. Verification Methods:
   - Knowledge assessments
   - Completion tracking
   - Compliance reporting
   - Performance metrics

### Evidence

```sql
select 
  count(*) as total_users,
  sum(case when status = 'pass' then 1 else 0 end) as compliant_users,
  sum(case when status = 'fail' then 1 else 0 end) as non_compliant_users
from 
  user_training_status;
```
