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

      csv << ["Fulfillment ID:", "Line Item ID:", "Service ID:", "Service Name:", "Fulfilled Date:", "Current (Incorrect) Price:", "Calculated (Correct) Price:"]
      bar = ProgressBar.new(Fulfillment.count)

      Fulfillment.includes(:line_item, :service).find_each do |fulfillment|
        begin
          current_price = fulfillment.service_cost
          calculated_price = fulfillment.line_item.cost(fulfillment.funding_source, fulfillment.fulfilled_at)

          if current_price != calculated_price
            csv << [fulfillment.id, fulfillment.line_item.id, fulfillment.service.id, fulfillment.service.name, fulfillment.fulfilled_at.strftime('%m/%d/%Y'), current_price, calculated_price]
          end

          bar.increment!
        rescue Exception => e
          csv << ["fulfillment.id", "Error: #{e.message}"]
          bar.increment!
        end
      end
    end
  end
end