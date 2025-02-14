---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: mp-04
---

# MP-4: Media Storage

## Implementation Status: Implemented

## Control Statement

The organization:
a. Physically controls and securely stores digital media
b. Protects system media until destroyed or sanitized

## M-21-31 Mapping

This control maps to M-21-31 logging requirements:
- EL1: All storage operations must be logged
- EL2: Access to media must be monitored and logged
- IL2: Storage changes must generate security events

## Implementation

### Storage Controls

1. Physical Security:
   - AWS datacenter controls
   - Region redundancy
   - Availability zones
   - Physical access logs

2. Digital Protection:
   - Encryption at rest
   - Key rotation
   - Access logging
   - Versioning

3. Data Lifecycle:
   - Retention policies
   - Archival rules
   - Deletion procedures
   - Recovery options

4. Monitoring:
   - Access patterns
   - Security events
   - Policy violations
   - Compliance status

### Evidence

```sql
select
  bucket_name,
  versioning_enabled,
  lifecycle_rules
from
  aws_s3_bucket
where
  server_side_encryption_configuration is not null;
```
