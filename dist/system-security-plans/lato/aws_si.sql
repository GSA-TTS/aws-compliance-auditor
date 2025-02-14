-- Monitor malicious code protection
query "malware_protection" {
  sql = <<-EOQ
    select
      instance_id,
      tags,
      case
        when tags->>'AntiMalware' is null then 'fail'
        when tags->>'LastScan' < (current_date - interval '24 hours')::text then 'fail'
        else 'pass'
      end as status
    from
      aws_ec2_instance;
  EOQ
}

-- Check system monitoring tools
query "monitoring_tools" {
  sql = <<-EOQ
    select
      name,
      metric_name,
      namespace,
      case
        when namespace not in ('AWS/CloudWatch', 'AWS/GuardDuty') then 'fail'
        when statistic_values is null then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudwatch_metric_alarm
    where
      namespace like 'AWS/%';
  EOQ
}

-- Verify integrity monitoring
query "integrity_checks" {
  sql = <<-EOQ
    select
      resource_id,
      configuration_state,
      case
        when configuration_state != 'OK' then 'fail'
        when last_update < now() - interval '24 hours' then 'warn'
        else 'pass'
      end as status
    from
      aws_config_configuration_item
    where
      resource_type in ('AWS::Lambda::Function', 'AWS::EC2::Instance');
  EOQ
}

-- Monitor security events
query "security_events" {
  sql = <<-EOQ
    select
      finding_id,
      title,
      severity_label,
      case
        when severity_label in ('CRITICAL', 'HIGH') then 'fail'
        when workflow_status = 'NEW' then 'warn'
        else 'pass'
      end as status
    from
      aws_securityhub_finding
    where
      record_state = 'ACTIVE';
  EOQ
}
