---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: ia-05
---

# IA-5: Authenticator Management

## Implementation Status: Implemented

## Control Statement

The organization manages system authenticators by:
a. Verifying identities before credential issuance
b. Establishing administrative procedures
c. Ensuring proper distribution and storage
d. Enforcing password complexity and change
e. Protecting against unauthorized disclosure

## Implementation

### Authenticator Controls

1. Password Management:
   - Minimum length: 14 characters
   - Complexity requirements
   - Maximum age: 90 days
   - History: 24 passwords
   - Storage: Hashed with salt

2. MFA Requirements:
   - Hardware tokens for privileged users
   - Virtual MFA for standard users
   - Backup codes management
   - Device registration

3. Access Key Management:
   - Rotation requirements
   - Usage monitoring
   - Automated expiration
   - Key pair protection

4. Certificate Management:
   - PKI integration
   - Certificate lifecycle
   - Revocation checking
   - Trust chain validation

### Evidence

```sql
select
  user_name,
  password_enabled,
  mfa_active,
  case
    when password_enabled and not mfa_active then 'fail'
    else 'pass'
  end as compliance_status
from
  aws_iam_user
where
  password_enabled = true;
```
