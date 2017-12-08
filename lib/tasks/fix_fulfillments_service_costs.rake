# Copyright © 2011-2017 MUSC Foundation for Research Development~
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
  desc "Fix fulfillments with bad service_cost values"
  task fix_fulfillments_service_cost: :environment do
    bar = ProgressBar.new(Fulfillment.count)

    CSV.open("tmp/fixed_fulfillments_service_costs.csv", "wb+") do |csv|
      proc = nil
      Fulfillment.find_each do |fulfillment|
        begin
          proc = fulfillment
          current_amount = fulfillment.service_cost
          calculated_amount = 0

          funding_source = fulfillment.line_item.protocol.sparc_funding_source
          date = fulfillment.fulfilled_at

          calculated_amount = fulfillment.line_item.cost(funding_source, date)

          if calculated_amount != current_amount
            csv << ["Protocol ID: #{fulfillment.line_item.protocol.sparc_id}", "Service Name: #{fulfillment.service_name}","Updating cost for fulfillment #{fulfillment.id} from #{current_amount} to #{calculated_amount}"]
            fulfillment.update_attribute(:service_cost, calculated_amount)
          end

          bar.increment! rescue nil
        rescue Exception => e
          csv << ["Protocol ID: #{fulfillment.line_item.protocol.sparc_id}", "Service Name: #{fulfillment.service_name}", "Error with #{proc.id}, Message: #{e.message}"]
          puts "Error with #{proc.inspect}, Message: #{e.message}"
          next
        end
      end
    end
  end
end
