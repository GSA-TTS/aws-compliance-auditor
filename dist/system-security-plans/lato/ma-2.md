---
implementation-status:
  - c-implemented
  - c-documented
control-origination:
  - c-system-specific-control
sort-id: ma-02
---

# MA-2: Controlled Maintenance

## Implementation Status: Implemented

## Control Statement

The organization:
a. Schedules maintenance
b. Documents maintenance
c. Reviews records
d. Performs preventive maintenance
e. Handles security impacts

## Implementation

### Maintenance Controls

1. Schedule Management:
   - Regular maintenance windows
   - Change control process
   - Impact assessment
   - Resource planning

2. Documentation:
   - Maintenance procedures
   - Change records
   - Security reviews
   - Access approvals

3. Security Controls:
   - Access restrictions
   - Activity logging
   - Tool management
   - Compliance checks

4. Monitoring:
   - Schedule tracking
   - Performance metrics
   - Security events
   - Compliance status

### Evidence

```sql
select
  count(*) as total_activities,
  sum(case when status = 'success' then 1 else 0 end) as successful,
  sum(case when status = 'failed' then 1 else 0 end) as failed
from
  aws_ssm_maintenance_window_execution
where
  scheduled_time > now() - interval '30 days';
```
