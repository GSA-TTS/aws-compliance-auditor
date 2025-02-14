-- Check MFA enforcement for root accounts
query "root_mfa_enabled" {
  sql = <<-EOQ
    select
      account_id,
      'Root Account' as user_name,
      case
        when mfa_active then 'pass'
        else 'fail'
      end as status
    from
      aws_iam_account_summary;
  EOQ
}

-- Check password policy complexity
query "password_policy_complexity" {
  sql = <<-EOQ
    select
      min_password_length,
      require_symbols,
      require_numbers,
      require_uppercase_characters,
      require_lowercase_characters,
      case
        when min_password_length < 14 then 'fail'
        when not require_symbols then 'fail' 
        when not require_numbers then 'fail'
        when not require_uppercase_characters then 'fail'
        when not require_lowercase_characters then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_password_policy;
  EOQ
}

-- Check authentication methods in use
query "authentication_methods" {
  sql = <<-EOQ
    select
      user_name,
      password_enabled,
      mfa_active,
      access_key_1_active,
      access_key_2_active,
      case
        when password_enabled and not mfa_active then 'fail'
        when access_key_1_active and access_key_2_active then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_user;
  EOQ
}
