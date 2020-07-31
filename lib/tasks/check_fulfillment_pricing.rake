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

namespace :data do
  task check_fulfillment_pricing: :environment do
    CSV.open("tmp/bad_fulfillment_pricing.csv", "wb") do |csv|

      csv << ["Protocol ID:", "Saved Funding Source:", "Protocol Funding Source:", "Quantity:", "Invoiced:", "Fulfillment ID:", "Line Item ID:", "Service ID:", "Service Name:", "Fulfilled Date:", "Current (Incorrect) Price:", "Calculated (Correct) Price:", "Error:"]
      bar = ProgressBar.new(Fulfillment.count)

      Fulfillment.includes(:service, line_item: :protocol).find_each do |fulfillment|
        begin
          calculated_price = fulfillment.line_item.cost(fulfillment.funding_source, fulfillment.fulfilled_at)
          service = fulfillment.service ? fulfillment.service : fulfillment.line_item.service

          if fulfillment.service_cost != calculated_price
            csv << [fulfillment.protocol.try(:srid), fulfillment.funding_source, fulfillment.protocol.try(:sparc_funding_source), fulfillment.quantity, (fulfillment.invoiced ? "Yes" : "No"), fulfillment.id, fulfillment.line_item_id, service.try(:id), service.try(:name), fulfillment.fulfilled_at.strftime('%m/%d/%Y'), fulfillment.service_cost, calculated_price, "N/A"]
          end

          bar.increment!
        rescue Exception => e
          service = fulfillment.service ? fulfillment.service : fulfillment.line_item.service

          csv << ["#{fulfillment.protocol.try(:sparc_id)} - #{fulfillment.protocol.try(:sub_service_request).try(:ssr_id)}", fulfillment.funding_source, fulfillment.protocol.try(:sparc_funding_source), fulfillment.quantity, (fulfillment.invoiced ? "Yes" : "No"), fulfillment.id, fulfillment.line_item_id, service.try(:id), service.try(:name), fulfillment.fulfilled_at.strftime('%m/%d/%Y'), fulfillment.service_cost, "N/A", e.message]
          bar.increment!
        end
      end
    end
  end
end