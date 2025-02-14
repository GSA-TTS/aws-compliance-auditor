-- Monitor S3 bucket encryption
query "s3_bucket_encryption" {
  sql = <<-EOQ
    select
      bucket_name,
      server_side_encryption_configuration,
      case
        when server_side_encryption_configuration is null then 'fail'
        when server_side_encryption_configuration ->> 'Rule' is null then 'fail'
        else 'pass'
      end as status
    from
      aws_s3_bucket;
  EOQ
}

-- Check media access controls
query "s3_bucket_access" {
  sql = <<-EOQ
    select
      bucket_name,
      bucket_policy,
      case
        when bucket_policy::jsonb @> '{"Statement":[{"Effect":"Allow","Principal":"*"}]}' then 'fail'
        when public_access_block_configuration->>'BlockPublicAcls' != 'true' then 'fail'
        when public_access_block_configuration->>'BlockPublicPolicy' != 'true' then 'fail'
        else 'pass'
      end as status
    from
      aws_s3_bucket;
  EOQ
}

-- Monitor media protection logging 
query "s3_bucket_logging" {
  sql = <<-EOQ
    select
      bucket_name,
      logging,
      case
        when logging is null then 'fail'
        when logging->>'TargetBucket' is null then 'fail'
        else 'pass'
      end as status
    from
      aws_s3_bucket;
  EOQ
}

-- Check media disposal controls
query "s3_bucket_lifecycle" {
  sql = <<-EOQ
    select
      bucket_name,
      lifecycle_rules,
      case
        when lifecycle_rules is null then 'fail'
        when jsonb_array_length(lifecycle_rules) = 0 then 'fail'
        else 'pass'
      end as status  
    from
      aws_s3_bucket;
  EOQ
}
