---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: mp-02
---

# MP-2: Media Access

## Implementation Status: Implemented

## Control Statement

The organization restricts access to digital media to authorized individuals.

## Implementation

### Access Control Framework

1. S3 Bucket Controls:
   - IAM policies
   - Bucket policies
   - Access points
   - ACL restrictions

2. Encryption Requirements:
   - Server-side encryption
   - KMS key management
   - Transit encryption
   - Client-side options

3. Monitoring Controls:
   - Access logging
   - CloudWatch alerts
   - CloudTrail events
   - Security Hub findings

4. Access Review:
   - Quarterly access reviews
   - Permission audits
   - Usage analysis
   - Compliance checks

### Evidence

```sql
select 
  bucket_name,
  public_access_block_configuration,
  server_side_encryption_configuration
from 
  aws_s3_bucket
where 
  bucket_policy is not null;
```
