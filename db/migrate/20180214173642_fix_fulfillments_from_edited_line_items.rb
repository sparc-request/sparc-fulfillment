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

class FixFulfillmentsFromEditedLineItems < ActiveRecord::Migration[5.0]
  def change
    #Find Line Items that have a name, and no fulfillments (bad data), and correct.
    LineItem.left_outer_joins(:fulfillments).where(fulfillments: { id: nil} ).where.not(name: nil).each do |line_item|
      #Double check is OTF, just in case (shouldn't ever happen)
      if line_item.service.one_time_fee
        #Remove name (this is now done automatically going forward)
        line_item.update_attributes(name: nil)
      end
    end

    #Find Fulfillments that have a service_id that doesn't match their line_item's service_id, and correct.
    Fulfillment.includes(:line_item).find_each do |fulfillment|
      begin
        if fulfillment.service_id != fulfillment.line_item.service_id
          line_item = fulfillment.line_item

          #Correct fulfillment service name, service id, and service cost
          fulfillment.service_id = line_item.service_id
          fulfillment.service_name = line_item.service.name
          fulfillment.service_cost = line_item.cost(line_item.protocol.sparc_funding_source, fulfillment.fulfilled_at)
          fulfillment.save(validate: false)

          #Fix line item service name
          line_item.name = line_item.service.name
          line_item.save(validate: false)

          #Destroy components that fit old service
          fulfillment.components.destroy_all

          puts "Fixing Fulfillment: #{fulfillment.id}"
        end
      rescue Exception => e
        puts "#"*20
        puts e.message
        puts "#"*20
      end
    end
  end
end
