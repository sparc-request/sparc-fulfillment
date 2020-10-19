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
  desc "Find and Fix Mismatched Procedure/LineItem Service IDs"
  task :fix_broken_service_ids => :environment do

    CSV.open("tmp/broken_service_ids.csv", "wb+") do |csv|
      @bar = ProgressBar.new(Procedure.count)

      unlinked_procedures = []
      corrected_line_items = []

      ##Completed Procedures (Have a saved cost)
      Procedure.complete.includes(visit: [:line_item]).find_each do |procedure|
        if procedure.visit && procedure.visit.line_item
          line_item = procedure.visit.line_item

          if procedure.service_id != line_item.service_id
            line_item.update_attributes(service_id: procedure.service_id)
            procedure.update_attributes(visit_id: nil)
            unlinked_procedures << procedure
            corrected_line_items << line_item
          end
        end

        @bar.increment!
      end

      Procedure.where.not(status: "complete").includes(visit: [:line_item]).find_each do |procedure|
        if procedure.visit && procedure.visit.line_item
          line_item = procedure.visit.line_item

          if procedure.service_id != line_item.service_id
            line_item.update_attributes(service_id: procedure.service_id)
            corrected_line_items << line_item
          end
        end
        @bar.increment!
      end

      csv << ["Completed Procedures that have been un-linked from a visit:"]
      csv << ["Procedure ID:", "New (correct) Service ID:", "Saved Service Cost:"]
      unlinked_procedures.each do |procedure|
        csv << [procedure.id, procedure.service_id, procedure.service_cost]
      end


      csv << ["List of Corrected Line Items:"]
      csv << ["Line Item ID:", "New (correct) Service ID:"]
      corrected_line_items.each do |line_item|
        csv << [line_item.id, line_item.service_id]
      end
    end
  end
end
