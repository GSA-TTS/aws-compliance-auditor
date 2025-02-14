-- Session locking query
query "aws_session_lock" {
  sql = <<-EOQ 
    select 
      account_id,
      session_policy,
      case
        when session_policy->>'InactivityTimeout' is null then 'fail'
        when (session_policy->>'InactivityTimeout')::int > 900 then 'fail' 
        else 'pass'
      end as status
    from
      aws_iam_account_settings;
  EOQ
}

-- Remote access controls 
query "aws_remote_access" {
  sql = <<-EOQ
    select
      resource_id,
      connections_config,
      case 
        when connections_config->>'VpnRequired' != 'true' then 'fail'
        when connections_config->>'MFARequired' != 'true' then 'fail'
        else 'pass'
      end as status
    from 
      aws_directory_service_directory;
  EOQ
}

-- Wireless access restrictions
query "aws_wireless_access" {
  sql = <<-EOQ 
    select
      resource_id,
      wireless_policy,
      case
        when wireless_policy->>'AllowedProtocols' != '["WPA2"]' then 'fail'
        when wireless_policy->>'ClientVPNRequired' != 'true' then 'fail'
        else 'pass'
      end as status
    from
      aws_workspaces_directory;
  EOQ
}

-- Monitoring privileged functions
query "aws_privileged_commands" {
  sql = <<-EOQ
    select 
      trail_name,
      event_selectors,
      case
        when event_selectors->>'ReadWriteType' != 'WriteOnly' then 'fail'
        when event_selectors->>'IncludeManagementEvents' != 'true' then 'fail'
        else 'pass' 
      end as status
    from
      aws_cloudtrail_trail;
  EOQ
}

-- Remote access monitoring
query "aws_remote_access" {
  sql = <<-EOQ
    select 
      resource_id,
      remote_access_policy,
      case
        when remote_access_policy->>'MFARequired' != 'true' then 'fail'
        when remote_access_policy->>'VPNRequired' != 'true' then 'fail'
        when remote_access_policy->>'EncryptionRequired' != 'true' then 'fail'
        else 'pass'
      end as status
    from
      aws_iam_account_settings;
  EOQ
}

-- Remote connection logging
query "aws_remote_connections" {
  sql = <<-EOQ
    select
      trail_name, 
      event_selectors,
      case
        when event_selectors->>'IncludeManagementEvents' != 'true' then 'fail'
        when event_selectors->>'ReadWriteType' != 'All' then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudtrail_trail;
  EOQ
}
