module CWFSPARC

  module V1

    class APIv1 < Grape::API

      version 'v1', using: :path
      format :json

      http_basic do |username, password|

        begin
          username == ENV['SPARC_API_USERNAME'] &&
            password == ENV['SPARC_API_PASSWORD']
        rescue
          false
        end
      end

      resource :notifications do

        params do

          requires :notification, type: Hash do

            requires :sparc_id, type: Integer
            requires :kind, type: String
            requires :action, type: String,
                              values: ['create', 'update']
            requires :callback_url, type: String
          end
        end

        post do
          Notification.create params['notification']
        end
      end
    end
  end
end
