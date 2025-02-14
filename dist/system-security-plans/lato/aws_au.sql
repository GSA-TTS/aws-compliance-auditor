-- Check CloudTrail logging configuration
query "aws_cloudtrail_logging" {
  sql = <<-EOQ
    select
      trail_name,
      is_logging,
      case
        when is_logging = false then 'fail'
        when event_selectors->>'IncludeManagementEvents' != 'true' then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudtrail_trail;
  EOQ
}

-- Verify audit storage capacity
query "aws_audit_storage" {
  sql = <<-EOQ
    select 
      bucket_name,
      lifecycle_rules,
      case
        when lifecycle_rules is null then 'fail'
        when bucket_policy is null then 'fail'
        else 'pass'
      end as status
    from
      aws_s3_bucket
    where
      tags->>'Audit' = 'true';
  EOQ
}

-- Monitor audit processing failures 
query "aws_audit_failures" {
  sql = <<-EOQ
    select
      trail_name,
      cloudwatch_logs_role_arn,
      case
        when cloudwatch_logs_role_arn is null then 'fail'
        when cloudwatch_logs_log_group_name is null then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudtrail_trail;
  EOQ
}

-- Check audit record generation
query "aws_audit_records" {
  sql = <<-EOQ
    select
      trail_name,
      event_selectors,
      case  
        when event_selectors is null then 'fail'
        when event_selectors->>'ReadWriteType' != 'All' then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudtrail_trail;
  EOQ
}
