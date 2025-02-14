-- Check backup configurations
query "backup_config" {
  sql = <<-EOQ
    select
      arn,
      backup_plan_id,
      case
        when rules is null then 'fail'
        when jsonb_array_length(rules) = 0 then 'fail'
        else 'pass'
      end as status
    from
      aws_backup_plan;
  EOQ
}

-- Monitor backup job status
query "backup_job_status" {
  sql = <<-EOQ
    select
      job_id,
      backup_vault_name,
      state,
      case
        when state != 'COMPLETED' then 'fail'
        when completion_date < (current_date - interval '24 hours') then 'warn'
        else 'pass'
      end as status
    from
      aws_backup_job
    where
      state != 'RUNNING';
  EOQ
}

-- Check recovery point retention
query "recovery_point_retention" {
  sql = <<-EOQ
    select
      backup_vault_name,
      recovery_point_arn,
      lifecycle->>'DeleteAfterDays' as retention_days,
      case
        when lifecycle->>'DeleteAfterDays' is null then 'fail'
        when (lifecycle->>'DeleteAfterDays')::int < 30 then 'fail'
        else 'pass'
      end as status
    from
      aws_backup_recovery_point;
  EOQ
}

-- Monitor backup vault access
query "backup_vault_access" {
  sql = <<-EOQ
    select
      name,
      arn,
      access_policy,
      case
        when access_policy::jsonb @> '{"Statement":[{"Effect":"Allow","Principal":"*"}]}' then 'fail'
        else 'pass'
      end as status
    from
      aws_backup_vault;
  EOQ
}
