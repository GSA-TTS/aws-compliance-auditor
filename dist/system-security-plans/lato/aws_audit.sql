-- Check CloudTrail log validation
query "cloudtrail_log_validation" {
  sql = <<-EOQ
    select
      trail_name,
      log_file_validation_enabled,
      case
        when not log_file_validation_enabled then 'fail'
        else 'pass'
      end as status
    from 
      aws_cloudtrail_trail;
  EOQ
}

-- Check audit record generation settings
query "audit_record_generation" {
  sql = <<-EOQ
    select
      trail_name,
      include_global_service_events,
      is_multi_region_trail,
      case
        when not include_global_service_events then 'fail'
        when not is_multi_region_trail then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudtrail_trail;
  EOQ
}

-- Check audit record content completeness
query "audit_record_content" {
  sql = <<-EOQ
    select 
      event_name,
      event_source,
      event_time,
      case
        when read_write_type is null then 'fail'
        when event_source is null then 'fail'
        when user_identity is null then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudtrail_trail_event;
  EOQ
}
