-- Monitor vendor-supplied software
query "vendor_software_updates" {
  sql = <<-EOQ
    select
      instance_id,
      platform_name,
      platform_version,
      case
        when platform_version < latest_version then 'fail'
        else 'pass'
      end as status
    from
      aws_ec2_instance
    where
      platform_name is not null;
  EOQ
}

-- Check development environments
query "development_environments" {
  sql = <<-EOQ
    select 
      name,
      tags,
      case
        when tags->>'Environment' = 'Production' then 'fail'
        when tags->>'Environment' is null then 'fail'
        else 'pass'
      end as status
    from
      aws_vpc
    where
      tags->>'Purpose' = 'Development';
  EOQ
}

-- Monitor third-party services
query "third_party_services" {
  sql = <<-EOQ
    select
      name,
      type,
      last_status_check,
      case
        when last_status_check < now() - interval '24 hours' then 'fail'
        when status != 'ACTIVE' then 'fail'
        else 'pass'
      end as status
    from
      aws_marketplace_subscription;
  EOQ
}

-- Check system documentation
query "system_documentation" {
  sql = <<-EOQ
    select
      resource_id,
      tags,
      case
        when tags->>'Documentation' is null then 'fail'
        when tags->>'LastReview' < (current_date - interval '365 days')::text then 'fail'
        else 'pass'
      end as status
    from
      aws_config_configuration_item
    where
      resource_type in ('AWS::EC2::Instance', 'AWS::Lambda::Function');
  EOQ
}
