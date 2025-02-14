---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: ia-02
---

# IA-2: Identification and Authentication

## Implementation Status: Implemented

## Control Statement

The system uniquely identifies and authenticates organizational users.

## Implementation

### Authentication Framework

1. User Identification:
   - Unique user IDs
   - Role-based access
   - Federation support
   - External identity providers

2. Authentication Methods:
   - Multi-factor authentication
   - Password policies
   - Hardware tokens
   - Biometric factors

3. Access Management:
   - Session controls
   - Login restrictions
   - Account lockout
   - Password rotation

4. Monitoring & Compliance:
   - Failed attempts tracking
   - Suspicious activity alerts
   - Compliance reporting
   - Access reviews

### Evidence

```sql
select
  case
    when min_password_length >= 14
    and require_symbols
    and require_numbers
    and require_uppercase_characters
    and require_lowercase_characters
    and password_reuse_prevention >= 24
    and max_password_age <= 90
    then 'pass'
    else 'fail'
  end as password_policy_status
from
  aws_iam_password_policy;
