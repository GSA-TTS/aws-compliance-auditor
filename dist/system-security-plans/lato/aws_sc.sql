-- Check encryption in transit
query "encryption_in_transit" {
  sql = <<-EOQ
    select
      name,
      type,
      case
        when type = 'AWS::ApiGateway::Stage' 
          and not ssl_policy = 'TLS_1_2' then 'fail'
        when type = 'AWS::ElasticLoadBalancing::LoadBalancer'
          and not listeners @> '[{"Protocol": "HTTPS"}]' then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudformation_stack_resource
    where
      type in ('AWS::ApiGateway::Stage', 'AWS::ElasticLoadBalancing::LoadBalancer');
  EOQ
}

-- Monitor KMS key usage
query "kms_key_rotation" {
  sql = <<-EOQ
    select
      key_id,
      key_manager,
      enabled,
      rotation_enabled,
      case
        when not enabled then 'fail'
        when key_manager = 'CUSTOMER' and not rotation_enabled then 'fail'
        else 'pass'
      end as status
    from
      aws_kms_key;
  EOQ
}

-- Check TLS versions
query "tls_policy" {
  sql = <<-EOQ
    select
      name,
      ssl_policy,
      case
        when ssl_policy not like 'TLS_1_2%' then 'fail'
        else 'pass'
      end as status
    from
      aws_cloudfront_distribution;
  EOQ
}

-- Check secure communications
query "secure_communications" {
  sql = <<-EOQ
    select 
      bucket_name,
      bucket_policy,
      case
        when bucket_policy::jsonb @> '{"Statement":[{"Effect":"Allow","Principal":"*","Action":"s3:*"}]}' then 'fail'
        when versioning_enabled = false then 'fail'
        else 'pass'
      end as status
    from
      aws_s3_bucket
    where 
      bucket_policy is not null;
  EOQ
}
