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
  desc 'Add invoiced_date value to fulfillments and procedures that have been previously flagged as invoiced'
  task add_invoiced_date_to_fulfillments_and_procedures: :environment do
    puts "*"*10 + " Adding invoiced_date to invoiced fulfillments... " + "*"*10
    bar = ProgressBar.new(Fulfillment.count)
    invoiced_fulfillments = Fulfillment.joins(:notes).where(invoiced: true)
    invoiced_fulfillments.find_each do |fulfillment|
      begin
        date = fulfillment.notes.last.updated_at
        fulfillment.update_attributes invoiced_date: date

        bar.increment! rescue nil

      rescue => exception
        puts "Error with #{fulfillment.id}, Message: #{exception.message}"
        bar.increment! rescue nil
        next
      end
    end
    puts "*"*10 + " #{invoiced_fulfillments.count} fulfillment records updated. " + "*"*10

    puts "*"*10 + " Adding invoiced_date to invoiced procedures... " + "*"*10
    bar = ProgressBar.new(Procedure.count)
    invoiced_procedures = Procedure.joins(:notes).where(invoiced: true)
    invoiced_procedures.find_each do |procedure|
      begin
        date = procedure.notes.last.updated_at
        procedure.update_attributes invoiced_date: date
        bar.increment! rescue nil
      rescue => exception
        puts "Error with #{procedure.inspect}, Message: #{exception.message}"
        bar.increment! rescue nil
        next
      end
    end
    puts "*"*10 + " #{invoiced_procedures.count} procedure records updated. " + "*"*10
  end
end
