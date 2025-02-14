---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: au-02
---

# AU-2: Audit Events

## Implementation Status: Implemented

## Control Statement

The organization:
a. Determines events to be audited on information systems
b. Coordinates audit events with security monitoring and incident response
c. Reviews audit events annually or when changes occur

## Implementation

### Audit Framework

1. Event Categories:
   - Authentication attempts
   - Resource access
   - Data changes
   - System events

2. Monitoring Controls:
   - CloudTrail logging
   - CloudWatch metrics
   - S3 access logs
   - VPC flow logs

3. Review Process:
   - Annual assessments
   - Change triggers
   - Risk analysis
   - Control updates

### Evidence
