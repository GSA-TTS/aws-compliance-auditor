-- Monitor maintenance accounts
query "maintenance_account_status" {
  sql = <<-EOQ
    select
      user_name,
      password_last_used,
      password_enabled,
      mfa_active,
      case
        when password_enabled and not mfa_active then 'fail'
        when password_last_used < current_date - interval '90 days' then 'warn'
        else 'pass'
      end as status
    from
      aws_iam_user
    where
      user_name like '%maint%'
      or tags->>'Purpose' = 'Maintenance';
  EOQ
}

-- Check maintenance access logging
query "maintenance_activity_logs" {
  sql = <<-EOQ
    select
      event_name,
      user_identity->>'userName' as user_name,
      event_time,
      case
        when event_source like '%iam%' and event_name like '%Update%' then 'fail'
        when event_source like '%ec2%' and event_name like '%Modify%' then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudtrail_trail_event
    where
      user_identity->>'userName' like '%maint%';
  EOQ
}

-- Monitor maintenance tools
query "maintenance_tool_status" {
  sql = <<-EOQ
    select
      name,
      instance_id,
      tags,
      case
        when tags->>'MaintenanceTool' is null then 'fail'
        when tags->>'LastVerification' < (current_date - interval '30 days')::text then 'fail'
        else 'pass'
      end as status
    from
      aws_ssm_managed_instance
    where
      tags->>'Purpose' = 'Maintenance';
  EOQ
}
