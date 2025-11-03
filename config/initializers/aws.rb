require "aws-sdk-s3"

aws_creds = Rails.application.credentials.aws

Aws.config.update(
  region: aws_creds[:region],
  credentials: Aws::Credentials.new(aws_creds[:access_key_id], aws_creds[:secret_access_key])
)
