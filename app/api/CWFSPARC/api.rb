module CWFSPARC
  class API < Grape::API
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
        requires :id, type: Integer, desc: "Protocol ID"
        requires :ssr_id, type: Integer, desc: "Sub Service Request ID"
      end
      post do
        # authenticate!
        params
        'WOOOOOO'
      end
    end
  end
end