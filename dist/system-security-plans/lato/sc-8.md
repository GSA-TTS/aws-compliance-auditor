---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: sc-08
---

# SC-8: Transmission Confidentiality and Integrity

## Implementation Status: Implemented

## Control Statement

The information system protects the:
a. Confidentiality of transmitted information
b. Integrity of transmitted information

## Implementation

### Security Controls

1. Encryption in Transit:
   - TLS 1.2+ enforcement
   - Certificate management
   - Key rotation
   - Protocol validation

2. Network Protection:
   - VPC encryption
   - Load balancer security
   - API Gateway controls
   - WAF rules

3. Monitoring:
   - Protocol compliance
   - Certificate expiration
   - Encryption status
   - Security events

4. Implementation Evidence:
```sql
select 
  name,
  ssl_policy,
  viewer_certificate_minimum_ssl_version,
  case
    when ssl_policy not like 'TLS_1_2%' then 'fail'
    else 'pass'
  end as status
from 
  aws_cloudfront_distribution;
```
