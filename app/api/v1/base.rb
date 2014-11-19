module CWFSPARC

  module V1

    class APIv1 < Grape::API

      version 'v1', using: :path
      format :json

      helpers do
        def current_user
          @current_user ||= User.authorize!(env)
        end

        def authenticate!
          error!('401 Unauthorized', 401) unless current_user
        end
      end

      resource :protocols do
        desc "Receive notification for protocols"
        params do
          requires :protocol_id, type: Integer, desc: "Protocol ID"
          requires :sub_service_request_id, type: Integer, desc: "Sub Service Request ID"
        end
        post do
          # authenticate!
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
