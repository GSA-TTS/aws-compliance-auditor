-- Check Security Assessment scheduling
query "security_assessment_schedule" {
  sql = <<-EOQ
    select
      name,
      description,
      schedule_expression,
      case
        when schedule_expression is null then 'fail'
        when schedule_expression not like 'cron%' then 'fail'
        else 'pass'
      end as status
    from
      aws_eventbridge_rule
    where 
      name like '%security-assessment%';
  EOQ
}

-- Monitor assessment findings
query "assessment_findings" {
  sql = <<-EOQ
    select
      id,
      title,
      description,
      severity,
      case
        when severity in ('CRITICAL', 'HIGH') then 'fail'
        else 'info'
      end as status
    from
      aws_securityhub_finding
    where
      workflow_status != 'RESOLVED'
      and record_state = 'ACTIVE';
  EOQ
}

-- Track remediation status
query "remediation_tracking" {
  sql = <<-EOQ
    select
      id,
      title,
      remediation_recommendation,
      remediation_status,
      case
        when remediation_status = 'PENDING' then 'fail'
        else 'pass'
      end as status
    from
      aws_securityhub_finding
    where
      workflow_status = 'IN_PROGRESS';
  EOQ
}

-- Monitor assessment schedules
query "aws_assessment_schedule" {
  sql = <<-EOQ
    select 
      resource_id,
      assessment_status,
      case
        when last_assessment_date < (current_date - interval '365' day) then 'fail'
        when assessment_status != 'completed' then 'fail'
        else 'pass'
      end as status
    from
      aws_securityhub_standards_control;
  EOQ
}

-- Check security scanning configurations
query "aws_security_scanning" {
  sql = <<-EOQ
    select
      name,
      scanning_config,
      case
        when scanning_config->>'Enabled' != 'true' then 'fail'
        when scanning_config->>'ScanFrequency' != 'FIFTEEN_MINUTES' then 'fail'
        else 'pass'
      end as status
    from
      aws_inspector_assessment_template;
  EOQ
}

-- Monitor system interconnections 
query "aws_interconnections" {
  sql = <<-EOQ
    select
      id,
      connection_status,
      security_config,
      case
        when connection_status != 'active' then 'fail'
        when security_config->>'CrossAccountAccess' = 'true' then 'fail' 
        else 'pass'
      end as status
    from
      aws_vpc_peering_connection;
  EOQ
}

-- Check VPC endpoint configurations
query "aws_vpc_endpoints" {
  sql = <<-EOQ
    select 
      vpc_endpoint_id,
      vpc_id,
      security_groups,
      case
        when security_groups is null then 'fail'
        when jsonb_array_length(security_groups) = 0 then 'fail'
        else 'pass'
      end as status 
    from
      aws_vpc_endpoint;
  EOQ
}

-- Review private link services
query "aws_vpc_privatelink" {
  sql = <<-EOQ 
    select
      service_id,
      service_name,
      permissions,
      case
        when permissions->>'AllowedPrincipals' = '*' then 'fail'
        else 'pass'
      end as status
    from  
      aws_vpc_endpoint_service;
  EOQ
}
