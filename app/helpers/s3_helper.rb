module S3Helper
  def presigned_s3_url(key, expires_in: 3600)
    return nil if key.blank?

    presigner = s3_presigner
    bucket_name = Rails.application.credentials.aws[:s3_bucket_name]

    presigner.presigned_url(:get_object, bucket: bucket_name, key: key, expires_in: expires_in)
  end

  private

  def s3_presigner
    @s3_presigner ||= begin
      aws_creds = Rails.application.credentials.aws

      s3_client = Aws::S3::Client.new(
        region:            aws_creds[:region],
        access_key_id:     aws_creds[:access_key_id],
        secret_access_key: aws_creds[:secret_access_key]
      )

      Aws::S3::Presigner.new(client: s3_client)
    end
  end
end
