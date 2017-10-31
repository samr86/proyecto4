module S3Client
    module_function
  
    def client
        @client ||= Aws::S3::Client.new(profile: 'oherazo', region: ENV['S3_REGION'])
    end
end