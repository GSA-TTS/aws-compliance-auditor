# AWS Compliance Auditor Specification
# This file defines the specifications for auditing AWS compliance.

# Define the AWS services to be audited
services:
    - EC2
    - S3
    - RDS
    - IAM

# Define the compliance standards to be checked
standards:
    - CIS AWS Foundations Benchmark
    - NIST 800-53

# Define the regions to be audited
regions:
    - us-east-1
    - us-east-2    
    - us-west-1
    - us-west-2

# Define the frequency of audits
frequency: daily

# Define the notification settings
#notifications:
#    email: compliance-team@example.com
#    slack: #compliance-alerts