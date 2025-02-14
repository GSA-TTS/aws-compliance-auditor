-- Check IAM password policy
query "iam_password_policy" {
  sql = <<-EOQ
    select
      min_password_length,
      require_lowercase_characters,
      require_uppercase_characters,
      require_numbers,
      require_symbols,
      max_password_age,
      password_reuse_prevention,
      case
        when min_password_length < 14 then 'fail'
        when not require_lowercase_characters then 'fail'
        when not require_uppercase_characters then 'fail'
        when not require_numbers then 'fail'
        when not require_symbols then 'fail'
        when max_password_age > 90 then 'fail'
        when password_reuse_prevention < 24 then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_password_policy;
  EOQ
}

-- Check IAM users MFA configuration
query "iam_user_mfa" {
  sql = <<-EOQ
    select
      user_name,
      password_enabled,
      mfa_active,
      case
        when password_enabled and not mfa_active then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_user;
  EOQ
}

-- Check IAM roles with admin access
query "iam_admin_roles" {
  sql = <<-EOQ
    with admin_policies as (
      select 
        arn,
        name
      from 
        aws_iam_policy
      where 
        policy_std -> 'Statement' @> '[{"Effect": "Allow", "Action": "*", "Resource": "*"}]'::jsonb
    )
    select
      r.role_name,
      r.arn,
      p.name as policy_name,
      'fail' as status
    from
      aws_iam_role r
      join admin_policies p on r.attached_policy_arns ? p.arn;
  EOQ
}

-- Monitor IAM role permissions changes
query "iam_role_changes" {
  sql = <<-EOQ 
    select
      event_name,
      user_identity->>'userName' as user_name,
      event_time,
      response_elements,
      'fail' as status 
    from
      aws_cloudtrail_trail_event
    where
      event_name like 'Create%Role' 
      or event_name like 'Delete%Role'
      or event_name like 'Update%Role'
      or event_name like 'Attach%RolePolicy'
      or event_name like 'Detach%RolePolicy';
  EOQ
}

-- Monitor IAM policy changes
query "iam_policy_changes" {
  sql = <<-EOQ
    select 
      event_name,
      user_identity->>'userName' as user_name,
      event_time,
      request_parameters,
      'fail' as status
    from
      aws_cloudtrail_trail_event  
    where
      event_name like '%Policy%'
      and event_name not like '%Get%'
      and event_name not like '%List%';
  EOQ
}
