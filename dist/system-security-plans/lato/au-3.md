---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: au-03
---

# AU-3: Content of Audit Records

## Implementation Status: Implemented

## Control Statement

The information system generates audit records containing information that establishes:
- What type of event occurred
- When the event occurred  
- Where the event occurred
- Source of the event
- Outcome of the event
- Identity of associated individuals/subjects

## Implementation

### Audit Content Framework

1. Required Fields:
   - Event timestamp
   - Event type
   - Resource ID
   - User identity
   - Source IP
   - Action status

2. Record Sources:
   - CloudTrail logs
   - S3 access logs
   - VPC flow logs
   - CloudWatch logs

3. Storage Controls:
   - Encryption at rest
   - Access restrictions
   - Retention policies
   - Backup procedures

### Evidence
