class ConcursosController < ApplicationController

    def new
    end

    def create
        fechaInicio = ""
        if params["concurso"]["fechaInicio(3i)"].length === 1
            fechaInicio = "0" + params["concurso"]["fechaInicio(3i)"] + "/"
        else
            fechaInicio = params["concurso"]["fechaInicio(3i)"] + "/"
        end

        if params["concurso"]["fechaInicio(2i)"].length === 1
            fechaInicio = fechaInicio + "0" + params["concurso"]["fechaInicio(2i)"] + "/"
        else
            fechaInicio = fechaInicio + params["concurso"]["fechaInicio(2i)"] + "/"
        end

        fechaInicio = fechaInicio + params["concurso"]["fechaInicio(1i)"]

        fechaFin = ""
        if params["concurso"]["fechaFin(3i)"].length === 1
            fechaFin = "0" + params["concurso"]["fechaFin(3i)"] + "/"
        else
            fechaFin = params["concurso"]["fechaFin(3i)"] + "/"
        end

        if params["concurso"]["fechaFin(2i)"].length === 1
            fechaFin = fechaFin + "0" + params["concurso"]["fechaFin(2i)"] + "/"
        else
            fechaFin = fechaFin + params["concurso"]["fechaFin(2i)"] + "/"
        end

        fechaFin = fechaFin + params["concurso"]["fechaFin(1i)"]

        # Se sube imagen a S3
        File.open(params["concurso"]["imagen"].path, "r") do |aFile|
            a = S3Client.client.put_object(bucket: ENV['S3_BUCKET'], key: params["concurso"]["URL"] + "/" + File.basename(params["concurso"]["imagen"].path), body: aFile)
            p a
        end
        
        # Se crea elemento a subir a DynamoDB
        item = {
            admin: current_user.id.to_s,
            nombre: params["concurso"]["nombre"],
            imagen: "https://s3-" + ENV['S3_REGION'] + ".amazonaws.com/" + ENV['S3_BUCKET'] + "/" + params["concurso"]["URL"] + "/" + File.basename(params["concurso"]["imagen"].path),
            url: params["concurso"]["URL"],
            fechaInicio: fechaInicio,
            fechaFin: fechaFin,
            descripcionPremio: params["concurso"]["descripcionPremio"]
        }

        params = {
            table_name: 'Concursos',
            item: item
        }

        # Se sube elemento a DynamoDB
        begin
            result = DynamodbClient.client.put_item(params)
        rescue  Aws::DynamoDB::Errors::ServiceError => error
            puts 'Unable to add Concurso:'
            puts error.message
        end

        respond_to do |format|
            format.html { redirect_to my_Competitions_url }
            format.json { head :no_content }
        end
      
        
    end

    def myCompetitions
        
        params = {
            table_name: 'Concursos',
            index_name: "admin-index",
            key_condition_expression: "admin = :v_admin",
            expression_attribute_values: {
                ":v_admin" => current_user.id.to_s 
            }
        }
        
        begin
            result = DynamodbClient.client.query(params)
            
            if result.items == nil
                p 'Could not find competition'
                exit 0
            end

            result = result.items
            @concursos = []
            for i in result
                param = {
                    nombre: i["nombre"],
                    fechaInicio: i["fechaInicio"],
                    fechaFin: i["fechaFin"],
                    imagen: i["imagen"],
                    url: i["url"]
                }
                @concursos.push(param)
            end

        rescue  Aws::DynamoDB::Errors::ServiceError => error
            puts 'Unable to find competition:'
            puts error.message
        end
        
    end

    def show

        ## Se obtiene información del concurso
        param = {
            table_name: 'Concursos',
            key: {
                url: params["url"]
            }
        }

        result = DynamodbClient.client.get_item(param)
        p result
          if result.item == nil
            puts 'Could not find movie'
            exit 0
          end
        
        i = result.item
        @concurso = {
            :nombre => i["nombre"],
            :fechaInicio => i["fechaInicio"],
            :fechaFin => i["fechaFin"],
            :imagen => i["imagen"],
            :url => i["url"]
          }

        ## Se obtiene información de los videos del concurso
        param = {
            table_name: 'Videos',
            index_name: "url_concurso-index",
            key_condition_expression: "url_concurso = :v_url",
            expression_attribute_values: {
                ":v_url" => params["url"] 
            }
        }
        
        begin
            result = DynamodbClient.client.query(param)
            
            if result.items == nil
                p 'Could not find any videos'
                exit 0
            end

            result = result.items
            @videos = []
            for i in result
                param = {
                    nombres: i["nombres"],
                    apellidos: i["apellidos"],
                    email: i["email"],
                    videoOriginal: i["videoOriginal"],
                    estado: i["estado"],
                    videoNuevo: i["videoNuevo"]
                }
                @videos.push(param)
            end

        rescue  Aws::DynamoDB::Errors::ServiceError => error
            puts 'Unable to find videos:'
            puts error.message
        end

    end
    

    def ver
    end

    def borrar
        param = {
            table_name: 'Concursos',
            key: {
                url: params["url"],
                admin: current_user.id.to_s
            }
        }

        result = DynamodbClient.client.delete_item(param)

        respond_to do |format|
            format.html { redirect_to my_Competitions_url }
            format.json { head :no_content }
        end
      
    end

    def modificar
        @concurso ={
            :url => params["url"]
        }
    end

    def actualizar

    end 

    def all
        params = {
            table_name: 'Concursos'
        }
        
        begin
            result = DynamodbClient.client.scan(params)
            
            if result.items == nil
                p 'Could not find competition'
                exit 0
            end

            result = result.items
            @concursos = []
            for i in result
                param = {
                    nombre: i["nombre"],
                    fechaInicio: i["fechaInicio"],
                    fechaFin: i["fechaFin"],
                    imagen: i["imagen"],
                    url: i["url"]
                }
                @concursos.push(param)
            end

        rescue  Aws::DynamoDB::Errors::ServiceError => error
            puts 'Unable to find competition:'
            puts error.message
        end
    end

    def showParticipant
        
        ## Se obtiene información del concurso
        param = {
            table_name: 'Concursos',
            key: {
                url: params["url"]
            }
        }

        result = DynamodbClient.client.get_item(param)
        p result
            if result.item == nil
            puts 'Could not find movie'
            exit 0
            end
        
        i = result.item
        @concurso = {
            :nombre => i["nombre"],
            :fechaInicio => i["fechaInicio"],
            :fechaFin => i["fechaFin"],
            :imagen => i["imagen"],
            :url => i["url"]
            }

        ## Se obtiene información de los videos del concurso
        param = {
            table_name: 'Videos',
            index_name: "url_concurso-index",
            key_condition_expression: "url_concurso = :v_url",
            expression_attribute_values: {
                ":v_url" => params["url"] 
            }
        }
        
        begin
            result = DynamodbClient.client.query(param)
            
            if result.items == nil
                p 'Could not find any videos'
                exit 0
            end

            result = result.items
            @videos = []
            for i in result
                param = {
                    nombres: i["nombres"],
                    apellidos: i["apellidos"],
                    email: i["email"],
                    videoOriginal: i["videoOriginal"],
                    estado: i["estado"],
                    videoNuevo: i["videoNuevo"]
                }
                if i["estado"] != "No convertido"
                    @videos.push(param)
                end
            end

        rescue  Aws::DynamoDB::Errors::ServiceError => error
            puts 'Unable to find videos:'
            puts error.message
        end

    end
end
