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
      csv << ["Procedure ID:", "Procedure Service ID:", "Visit => Line Item Service ID:", "Procedure Service Price:"]
      @bar = ProgressBar.new(Procedure.count)


      csv << ["Procedures that HAVE been completed"]
      csv << ["(Service cost has been saved locally)"]
      csv << ["Procedure ID:", "New (correct) Service ID:", "Old (incorrect) Service ID From Line Item:", "Saved Service Cost:"]

      completed_procedures = []
      Procedure.where.not(service_cost: nil).includes(visit: [:line_item]).find_each do |procedure|
        process_procedure(procedure, completed_procedures)
        @bar.increment!
      end

      completed_procedures.sort_by{|procedure| [procedure.service_id, procedure.visit.line_item.service_id]}.each do |procedure|
        csv << [procedure.id, procedure.service_id, procedure.visit.line_item.service_id, procedure.service_cost]
      end


      csv << ["Procedures that have NOT been completed"]
      csv << ["(Do not have a service cost saved on them locally)"]
      csv << ["Procedure ID:", "New (correct) Service ID:", "Old (incorrect) Service ID From Line Item:"]

      non_completed_procedures = []
      Procedure.where(service_cost: nil).includes(visit: [:line_item]).find_each do |procedure|
        process_procedure(procedure, non_completed_procedures)
        @bar.increment!
      end

      non_completed_procedures.sort_by{|procedure| [procedure.service_id, procedure.visit.line_item.service_id]}.each do |procedure|
        csv << [procedure.id, procedure.service_id, procedure.visit.line_item.service_id]
      end
    end
  end
end


def process_procedure(procedure, list)
  if procedure.visit && procedure.visit.line_item
    if procedure.service_id != procedure.visit.line_item.service_id
      list << procedure
    end
  end
end
