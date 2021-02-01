# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module CWFSPARC

  module V1

    class APIv1 < Grape::API

      version 'v1', using: :path
      format :json

      http_basic do |username, password|

        begin
          username == ENV['CWF_API_USERNAME'] &&
            password == ENV['CWF_API_PASSWORD']
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

      #For syncing of one time fee line items from SPARC
      resource :otf_sync_from_sparc do
        params do
          requires :sync, type: Hash do
            requires :action, type: String, values: ['create', 'update', 'destroy']
            requires :line_item, type: Hash do
              requires :sparc_id, type: Integer
              optional :quantity_requested, type: Integer
              optional :service_id, type: Integer
              optional :protocol_id, type: Integer
            end
          end
        end
        post do
          sync = params['sync']
          action = sync['action']
          line_item_hash = sync['line_item']

          ##If there are multiple (bad data) line items with the same sparc_id, this will just grab the first one as a fall back.
          line_item = LineItem.find_by_sparc_id(line_item_hash['sparc_id']) if (action == "update" or "destroy")

          if action == 'create'
            if LineItem.create(line_item_hash)
              success_message = {result: "success", detail: "created"}
            end
          elsif action == 'update'
            if line_item.update_attributes(line_items_hash)
              success_message = {result: "success", detail: "updated"}
            end
          elsif action == 'destroy'
            if line_item.destroy
              success_message = {result: "success", detail: "destroyed"}
            end
          end

          if success_message
            return success_message
          else
            return {result: "error"}
          end
        end
      end
    end
  end
end
