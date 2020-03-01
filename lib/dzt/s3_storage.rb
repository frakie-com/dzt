module DZT
  class S3Storage
    DEFAULT_ACL = 'public-read'
    DEFAULT_KEY = ''
    DEFAULT_REGION = nil
    #
    # @param s3_acl: ACL to use for storing, defaults to 'public-read'.
    # @param s3_bucket: Bucket to store tiles.
    # @param s3_key: Key to prefix stored files.
    # @param aws_id: AWS Id.
    # @param aws_secret: AWS Secret.
    #
    def initialize(options = {})
      @s3_acl = options[:s3_acl] || DEFAULT_ACL
      @s3_bucket = options[:s3_bucket]
      @s3_key = options[:s3_key] || DEFAULT_KEY
      @s3_region = options[:s3_region] || DEFAULT_REGION
      @s3_id = options[:aws_id]
      @s3_secret = options[:aws_secret]
    end

    def s3
      @s3 ||= begin
        require_fog!
        Fog::Storage.new(
          provider: 'AWS',
          region: @s3_region,
          aws_access_key_id: @s3_id,
          aws_secret_access_key: @s3_secret
        )
      end
    end

    # Currently does not supporting checking S3 fo overwritten files
    def exists?
      false
    end

    def storage_location(level)
      "#{@s3_key}/#{level}"
    end

    # no-op
    def mkdir(_path)
    end

    def write(file, dest, options = {})
      quality = options[:quality]
      s3.put_object(@s3_bucket, dest, file.to_blob { @quality = quality if quality },
                    'Content-Type' => file.mime_type,
                    'x-amz-acl' => @s3_acl
                   )
    end

    private

    def require_fog!
      require 'fog/aws'
    rescue LoadError => e
      STDERR.puts 'Fog is required for storing data in S3, run `gem install fog-aws`.'
      raise e
    end
  end
end
