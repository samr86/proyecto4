# Rake task to create activities table 

namespace :dynamodb_tables_v1 do
    desc "bundle exec rake dynamodb_tables_v1:create_concursos_table RAILS_ENV=<ENV>"
    task :create_concursos_table => :environment do
      puts "Creating activities table in #{Rails.env}\n"
      create_concursos_table
      puts "Completed task\n"
    end
  
    def create_concursos_table
  
        params = {
            table_name: 'Concursos',
            key_schema: [
                {
                    attribute_name: 'admin',
                    key_type: 'HASH'  #Partition key
                },
                {
                    attribute_name: 'title',
                    key_type: 'RANGE' #Sort key
                }
            ],
            attribute_definitions: [
                {
                    attribute_name: 'admin',
                    attribute_type: 'S'
                },
                {
                    attribute_name: 'title',
                    attribute_type: 'S'
                },
        
            ],
            provisioned_throughput: {
                read_capacity_units: 10,
                write_capacity_units: 10
          }
        }
  
      begin
        result = DynamodbClient.client.create_table(params)
        puts 'Created table: concursos\n Status: ' + result.table_description.table_status;
      rescue Aws::DynamoDB::Errors::ServiceError => error
        puts 'Unable to create table: concursos\n'
        puts "#{error.message}"
      end
    end
  end