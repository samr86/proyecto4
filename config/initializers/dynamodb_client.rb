## /config/initializers/dynamodb_client.rb
module DynamodbClient
    def self.initialize!
      client_config = if Rails.env.development?
                        {
                            region: 'us-west-2',
                            endpoint: 'http://localhost:8000'
                        }
                      else
                        {
                            access_key_id: Rails.application.secrets.dynamodb_access_key_id,
                            secret_access_key: Rails.application.secrets.dynamodb_secret_access_key,
                            region: Rails.application.secrets.dynamodb_region
                        }
                      end
      @client ||= Aws::DynamoDB::Client.new(client_config)
    end
  
    module_function
  
    def client
        client_config = if Rails.env.development?
        {
            region: 'us-west-2',
            endpoint: 'http://localhost:8000'
        }
      else
        {
            access_key_id: Rails.application.secrets.dynamodb_access_key_id,
            secret_access_key: Rails.application.secrets.dynamodb_secret_access_key,
            region: Rails.application.secrets.dynamodb_region
        }
      end
      @client ||= Aws::DynamoDB::Client.new(client_config)
    end
end