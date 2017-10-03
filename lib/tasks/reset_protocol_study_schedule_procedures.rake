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
  desc 'Reset participant procedures to current study schedule R and T quantities'
  task reset_participant_procedures: :environment do
    
    print "Which protocol would you like me to reset: "
    protocol_id = STDIN.gets.chomp

    print "Are you sure you want to reset #{protocol_id.to_i}? (Yes/No) "
    answer = STDIN.gets.chomp

    if answer == 'Yes'
      protocol = Protocol.find protocol_id.to_i

      puts "Gathering up per participant line items"
      line_items = protocol.line_items.includes(:service).where(:services => {:one_time_fee => false})
      bar = ProgressBar.new(line_items.count)

      line_items.each do |line_item|
        line_item.visits.each do |visit|
          visit.update_procedures visit.research_billing_qty, 'research_billing_qty'
          visit.update_procedures visit.insurance_billing_qty, 'insurance_billing_qty'
        end

        bar.increment! rescue nil
      end

      puts "Gathering up procedures"
      procedures = protocol.procedures
      bar = ProgressBar.new(procedures.count)
      
      procedures.each do |procedure|
        sparc_core = Organization.find procedure.sparc_core_id
        procedure.update_attribute(:sparc_core_name, sparc_core.name)

        bar.increment! rescue nil
      end
    else
      puts "Task aborted!"
    end
  end
end
