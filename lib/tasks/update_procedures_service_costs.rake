# Copyright © 2011-2023 MUSC Foundation for Research Development~
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
  desc "Fix procedures with bad service_cost values"
  task update_procedures_service_costs: :environment do

    logged_services = Set.new

    CSV.open("tmp/update_procedures_service_costs.csv", "wb+") do |csv|
      procedures = Procedure.joins(protocol: { line_items: :admin_rates }).where.not(completed_date: nil).distinct
      bar = ProgressBar.new(procedures.count)
      procedures.find_each do |procedure|

        begin
          current_amount = procedure.service_cost
          calculated_amount = 0

          funding_source = procedure.protocol.sparc_funding_source
          date = procedure.completed_date

          calculated_amount = procedure.send(:new_cost, funding_source, date)

          if calculated_amount != current_amount
            csv << ["Protocol ID: #{procedure.protocol.sparc_id}", "Service Name: #{procedure.service_name}","Updating cost for procedure #{procedure.id} from #{sprintf('%.2f', current_amount / 100.0)} to #{sprintf('%.2f', calculated_amount / 100.0)}"]
            #procedure.update_attribute(:service_cost, calculated_amount)
          end

          bar.increment! rescue nil
        rescue Exception => e
          unless logged_services.include?(procedure.service_name)
            csv << ["Protocol ID: #{procedure.protocol.sparc_id}", "Service Name: #{procedure.service_name}", "Error with #{procedure.id}, Message: #{e.message}"]
            puts "Error with #{procedure.inspect}, Message: #{e.message}"
            logged_services.add(procedure.service_name)
          end

          next
        end
      end
    end
  end
end
