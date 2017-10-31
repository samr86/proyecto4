class VideosController < ApplicationController
    def new
        @concurso ={
            :url => params["url"]
        }
    end

    def create
        # Se sube imagen a S3
        File.open(params["video"]["video"].path, "r") do |aFile|
            a = S3Client.client.put_object(bucket: ENV['S3_BUCKET'], key: params["video"]["url"] + "/videos/" + params["video"]["email"] + "/" + File.basename(params["video"]["video"].path), body: aFile)
            p a
        end

        # Se crea elemento a subir a DynamoDB
        codigo = SecureRandom.uuid
        item = {
            uuid: codigo,
            email: params["video"]["email"],
            videoOriginal: "https://s3-" + ENV['S3_REGION'] + ".amazonaws.com/" + ENV['S3_BUCKET'] + "/" + params["video"]["url"] + "/videos/" + params["video"]["email"] + "/" + File.basename(params["video"]["video"].path),
            estado: "No convertido",
            videoNuevo: nil,
            url_concurso: params["video"]["url"],
            nombres: params["video"]["nombres"],
            apellidos: params["video"]["apellidos"]
            
        }

        params = {
            table_name: 'Videos',
            item: item
        }

        # Se sube elemento a DynamoDB
        begin
            result = DynamodbClient.client.put_item(params)
        rescue  Aws::DynamoDB::Errors::ServiceError => error
            puts 'Unable to add Video:'
            puts error.message
        end

        # Se envia el mensaje a SQS
        begin
            result = SQSClient.client.send_message(queue_url: ENV['SQS_URL'], message_body: codigo)
        rescue  Aws::SQS::Errors::ServiceError => error
            puts 'Unable to add msg:'
            puts error.message
        end

        respond_to do |format|
            format.html { redirect_to all_concursos_url }
            format.json { head :no_content }
        end

    end
end
