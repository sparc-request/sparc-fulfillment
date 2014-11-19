module CWFSPARC

  module V1

    class APIv1 < Grape::API

      version 'v1', using: :path
      format :json

      http_basic do |username, password|

        begin
          username == ENV['SPARC_USERNAME'] &&
            password == ENV['SPARC_PASSWORD']
        rescue
          false
        end
      end

      resource :protocols do

        params do
          requires :protocol_id, type: Integer, desc: "Protocol ID"
          requires :sub_service_request_id, type: Integer, desc: "Sub Service Request ID"
        end

        post do

          protocol = Protocol.find_or_initialize_by(sparc_id: params[:id])
          if protocol.new_record?
            protocol.sparc_sub_service_request_id = params[:ssr_id]
            protocol.save
          else
            # Throw error already created
          end
          # url = "http://localhost:3000/v1/protocols.json"
          # data = {id: params[:id], ssr_id: params[:ssr_id]}
          # response = RestClient.get url, data, content_type: 'application/json'
          # puts response.inspect
        end
      end
    end
  end
end
