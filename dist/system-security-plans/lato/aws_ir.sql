-- Monitor GuardDuty findings
query "guardduty_incidents" {
  sql = <<-EOQ
    select
      title,
      description,
      severity,
      created_at,
      case
        when severity >= 7 then 'fail'
        when created_at < now() - interval '24 hours' 
          and workflow_status = 'NEW' then 'fail'
        else 'pass'
      end as status
    from
      aws_guardduty_finding
    where
      workflow_status != 'ARCHIVED';
  EOQ
}

-- Check incident response automation
query "incident_automation" {
  sql = <<-EOQ
    select
      rule_name,
      event_pattern,
      state,
      case
        when state != 'ENABLED' then 'fail'
        when event_pattern::jsonb -> 'source' ? 'aws.securityhub' then 'pass'
        else 'fail'
      end as status
    from
      aws_eventbridge_rule
    where
      rule_name like '%incident%';
  EOQ
}

-- Monitor security hub alerts
query "security_hub_incidents" {
  sql = <<-EOQ
    select
      title,
      severity_label,
      workflow_status,
      product_name,
      case
        when severity_label in ('CRITICAL', 'HIGH') 
          and workflow_status = 'NEW' then 'fail'
        when record_state != 'ACTIVE' then 'skip'
        else 'pass'
      end as status
    from
      aws_securityhub_finding;
  EOQ
}

-- Check incident response roles
query "incident_response_roles" {
  sql = <<-EOQ
    select
      role_name,
      attached_policy_arns,
      case
        when not attached_policy_arns ?| array[
          'arn:aws:iam::aws:policy/service-role/AWSIncidentManagerResolverPolicy'
        ] then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_role
    where
      role_name like '%incident%';
  EOQ
}

-- Check incident response plan status
query "incident_response_plan" {
  sql = <<-EOQ
    select
      name,
      tags,
      case
        when tags->>'LastReviewDate' is null then 'fail'
        when (tags->>'LastReviewDate')::date < current_date - interval '365 days' then 'fail'
        else 'pass'
      end as status
    from
      aws_s3_bucket
    where
      tags->>'Purpose' = 'IncidentResponse';
  EOQ
}

-- Monitor security incidents
query "active_incidents" {
  sql = <<-EOQ
    select
      id,
      title,
      created_at,
      severity_label,
      case
        when severity_label in ('CRITICAL', 'HIGH') 
          and workflow_status = 'NEW' then 'fail'
        when record_state != 'ACTIVE' then 'skip'
        else 'pass'
      end as status
    from
      aws_securityhub_finding
    where
      workflow_status not in ('RESOLVED', 'ARCHIVED');
  EOQ
}

-- Monitor incident handling time
query "incident_resolution_time" {
  sql = <<-EOQ
    select
      title,
      severity_label,
      created_at,
      updated_at,
      case
        when severity_label = 'CRITICAL' 
          and extract(epoch from updated_at - created_at)/3600 > 4 then 'fail'
        when severity_label = 'HIGH'
          and extract(epoch from updated_at - created_at)/3600 > 24 then 'fail'
        else 'pass'
      end as status
    from
      aws_securityhub_finding
    where
      workflow_status = 'RESOLVED';
  EOQ
}
