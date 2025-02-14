-- Monitor Security Hub findings
query "security_hub_findings" {
  sql = <<-EOQ
    select
      title,
      severity_label,
      compliance_status,
      workflow_status,
      case
        when severity_label in ('CRITICAL', 'HIGH') 
          and workflow_status != 'RESOLVED' then 'fail'
        when severity_label = 'MEDIUM' 
          and workflow_status != 'RESOLVED' 
          and created_at < now() - interval '30 days' then 'fail'
        else 'pass'
      end as status
    from
      aws_securityhub_finding
    where
      record_state = 'ACTIVE';
  EOQ
}

-- Track Inspector vulnerability assessments
query "inspector_assessments" {
  sql = <<-EOQ
    select
      name,
      assessment_run_name,
      finding_counts,
      case
        when finding_counts->>'High' != '0' then 'fail'
        when finding_counts->>'Medium' != '0' 
          and started_at < now() - interval '30 days' then 'fail'
        else 'pass'
      end as status
    from
      aws_inspector_assessment_run;
  EOQ
}

-- Monitor GuardDuty findings
query "guardduty_findings" {
  sql = <<-EOQ
    select
      title,
      description,
      severity,
      case
        when severity >= 7 then 'fail'
        when severity >= 4 and 
          created_at < now() - interval '30 days' then 'fail'
        else 'pass'
      end as status
    from
      aws_guardduty_finding
    where
      service_affected = true;
  EOQ
}

-- Check risk assessment documentation
query "risk_assessment_documentation" {
  sql = <<-EOQ
    select
      resource_id,
      tags,
      case
        when tags->>'RiskAssessment' is null then 'fail'
        when tags->>'LastAssessmentDate' < (current_date - interval '365 days')::text then 'fail'
        else 'pass'
      end as status
    from
      aws_config_configuration_item
    where
      resource_type in ('AWS::IAM::Role', 'AWS::EC2::Instance', 'AWS::Lambda::Function');
  EOQ
}
