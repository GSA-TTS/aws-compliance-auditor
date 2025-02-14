-- Check training completion status
query "training_completion" {
  sql = <<-EOQ
    select
      user_name,
      tags ->> 'LastTrainingDate' as last_training,
      case
        when tags ->> 'LastTrainingDate' is null then 'fail'
        when (tags ->> 'LastTrainingDate')::date < current_date - interval '365 days' then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_user
    where
      password_enabled = true;
  EOQ
}

-- Monitor privileged user training
query "privileged_training" {
  sql = <<-EOQ
    with privileged_users as (
      select distinct
        user_name
      from
        aws_iam_user_policy
      where
        policy_document::jsonb @> '{"Statement":[{"Effect":"Allow","Action":"*"}]}'
    )
    select
      u.user_name,
      u.tags ->> 'LastPrivilegedTraining' as last_training,
      case
        when u.tags ->> 'LastPrivilegedTraining' is null then 'fail'
        when (u.tags ->> 'LastPrivilegedTraining')::date < current_date - interval '180 days' then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_user u
      join privileged_users p on u.user_name = p.user_name;
  EOQ
}

-- Check training documentation
query "training_documentation" {
  sql = <<-EOQ
    select
      'Security Training' as document_type,
      tags ->> 'LastReviewDate' as last_review,
      case
        when tags ->> 'LastReviewDate' is null then 'fail'
        when (tags ->> 'LastReviewDate')::date < current_date - interval '365 days' then 'fail'
        else 'pass'
      end as status
    from
      aws_s3_bucket
    where
      tags ->> 'Purpose' = 'SecurityTraining';
  EOQ
}

-- Monitor user training status
query "user_training_status" {
  sql = <<-EOQ
    select
      user_name,
      tags ->> 'LastTrainingDate' as last_training,
      tags ->> 'TrainingType' as training_type,
      case
        when tags ->> 'LastTrainingDate' is null then 'fail'
        when (tags ->> 'LastTrainingDate')::date < current_date - interval '365 days' then 'fail'
        when tags ->> 'TrainingType' is null then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_user
    where
      user_name not like 'system-%';
  EOQ
}

-- Check role-based training
query "role_based_training" {
  sql = <<-EOQ
    select
      r.role_name,
      r.tags ->> 'RequiredTraining' as required_training,
      r.tags ->> 'LastTrainingVerification' as last_verification,
      case
        when r.tags ->> 'RequiredTraining' is null then 'fail'
        when r.tags ->> 'LastTrainingVerification' is null then 'fail'
        when (r.tags ->> 'LastTrainingVerification')::date < current_date - interval '180 days' then 'warn'
        else 'pass'
      end as status
    from
      aws_iam_role r
    where
      r.role_name like 'Security%';
  EOQ
}

-- Monitor training documentation
query "training_materials" {
  sql = <<-EOQ
    select 
      bucket_name,
      tags ->> 'ContentType' as content_type,
      tags ->> 'LastUpdate' as last_update,
      case
        when tags ->> 'ContentType' not in ('SecurityAwareness', 'RoleBased', 'Privileged') then 'fail'
        when (tags ->> 'LastUpdate')::date < current_date - interval '365 days' then 'fail'
        else 'pass'
      end as status
    from
      aws_s3_bucket
    where
      tags ->> 'Purpose' = 'Training';
  EOQ
}
