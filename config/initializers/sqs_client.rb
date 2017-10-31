module SQSClient
    module_function
  
    def client
        @client ||= Aws::SQS::Client.new(region: ENV['SQS_REGION'])
    end
end