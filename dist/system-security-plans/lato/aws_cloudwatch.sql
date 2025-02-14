-- Check CloudWatch Log Groups retention
query "cloudwatch_log_retention" {
  sql = <<-EOQ
    select 
      log_group_name,
      retention_in_days,
      case
        when retention_in_days < 365 then 'fail'
        when retention_in_days is null then 'fail' 
        else 'pass'
      end as status
    from
      aws_cloudwatch_log_group
    where 
      log_group_name like '/aws/lambda/%'
      or log_group_name like '/aws/apigateway/%';
  EOQ
}

-- Check CloudWatch Log Groups encryption 
query "cloudwatch_log_encryption" {
  sql = <<-EOQ
    select
      log_group_name,
      kms_key_id,
      case 
        when kms_key_id is null then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudwatch_log_group;
  EOQ
}

-- Check CloudWatch Metrics Export
query "cloudwatch_metrics_export" {
  sql = <<-EOQ
    select
      namespace,
      metric_name,
      case
        when metric_name not in ('CPUUtilization', 'MemoryUtilization') then 'skip'
        else 'pass'
      end as status
    from 
      aws_cloudwatch_metric;
  EOQ
}

-- Check CloudWatch Alarms Configuration
query "cloudwatch_alarms" {
  sql = <<-EOQ
    select
      alarm_name,
      metric_name,
      comparison_operator,
      threshold,
      case
        when actions_enabled = false then 'fail'
        when alarm_actions is null then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudwatch_alarm
    where
      namespace = 'AWS/Logs';
  EOQ
}

-- Check IAM access logging
query "cloudwatch_iam_logging" {
  sql = <<-EOQ
    select
      log_group_name,
      case
        when log_group_name not like '%/aws/iam/%' then 'fail'
        when retention_in_days < 365 then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudwatch_log_group
    where
      log_group_name like '%/aws/iam/%';
  EOQ
}

-- Monitor privileged access
query "cloudwatch_privileged_access" {
  sql = <<-EOQ
    select
      alarm_name,
      metric_name,
      comparison_operator,
      threshold,
      case
        when not actions_enabled then 'fail'
        when alarm_actions is null then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudwatch_alarm
    where
      namespace = 'AWS/IAM'
      and metric_name in ('ConsoleSignIn', 'AssumeRole');
  EOQ
}
