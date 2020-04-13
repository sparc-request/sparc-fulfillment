# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

namespace :data do
  desc "Fix Per Patient Line Items"
  task fix_per_patient_line_items: :environment do

    line_items = LineItem.joins(:service).where(sparc_id: nil, services: {one_time_fee: false})

    CSV.open("tmp/fix_per_patient_line_items_#{Time.now.strftime('%m%d%Y%H%M%S')}.csv", "wb") do |csv|
      csv << ["Line Item ID (in Fulfilllment)", "Service ID", "Service Name", "Arm ID", "Arm Name", "Protocol ID (in SPARCRequest)", "Protocol ID (in SPARCFulfillment)", "Request ID", "Sub Service Request ID", "Organization", "New Line Item Sparc ID", "Message"]

      line_items.each do |fulfillment_line_item|
        begin
          service_id = fulfillment_line_item.service_id
          arm_id = fulfillment_line_item.arm.sparc_id
          sub_service_request = Sparc::SubServiceRequest.find(fulfillment_line_item.protocol.sub_service_request_id)
          request_line_item = sub_service_request.line_items.joins(:line_items_visits).where(service_id: service_id, line_items_visits: {arm_id: arm_id}).first
          fulfillment_line_item_with_sparc_id = request_line_item ? fulfillment_line_item.protocol.line_items.where(sparc_id: request_line_item.id).first : nil #siblings with SPARCRequest line item id

          if fulfillment_line_item_with_sparc_id || request_line_item.nil?
            new_request_line_item = sub_service_request.line_items.create(service_request_id: sub_service_request.service_request_id, service_id: service_id, quantity: fulfillment_line_item.quantity_requested)
            fulfillment_line_item.update_attribute(:sparc_id, new_request_line_item.id)
            csv << ["#{fulfillment_line_item.id}", "#{service_id}", "#{fulfillment_line_item.service.name}", "#{arm_id}", "#{fulfillment_line_item.arm.name}", "#{fulfillment_line_item.protocol.sparc_id}", "#{fulfillment_line_item.protocol.id}", "#{fulfillment_line_item.protocol.srid}", "#{fulfillment_line_item.protocol.sub_service_request_id}", "#{fulfillment_line_item.service.organization.name}", "#{new_request_line_item.id}", "New SPARC Line Item created & Sparc ID (of Fulfillment Line Item Table) updated"]
          else
            fulfillment_line_item.update_attribute(:sparc_id, request_line_item.id)
            csv << ["#{fulfillment_line_item.id}", "#{service_id}", "#{fulfillment_line_item.service.name}", "#{arm_id}", "#{fulfillment_line_item.arm.name}", "#{fulfillment_line_item.protocol.sparc_id}", "#{fulfillment_line_item.protocol.id}", "#{fulfillment_line_item.protocol.srid}", "#{fulfillment_line_item.protocol.sub_service_request_id}", "#{fulfillment_line_item.service.organization.name}", "#{request_line_item.id}", "Sparc ID (of Fulfillment Line Item Table) updated"]
          end

          rescue Exception => e
            puts "Error with Line Item ID: #{fulfillment_line_item.id}, Message: #{e.message}"
            next
        end
      end
    end

  end
end
