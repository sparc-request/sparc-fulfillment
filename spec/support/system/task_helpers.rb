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

module System
  module TaskHelpers
    def create_tasks(count=1, protocol:)
      count.times { create(:task, protocol_id: protocol.id) }
    end

    def user_fills_in_new_task_form(task:, assignee:)
      # Wrap the entire form interaction so Capybara is blind to the rest of the page.
      # (Note: adjust the 'form' CSS selector if this form has a specific ID like '#new_task')
      within('form', match: :first) do
        select 'Study-level Task', from: 'Task Type'
        fill_in 'Patient Name', with: task.participant_name
        fill_in 'Protocol', with: task.protocol_id
        fill_in 'Visit', with: task.visit_name
        fill_in 'Arm', with: task.arm_name
        fill_in 'Task/Service', with: task.task
        
        select assignee.full_name, from: 'Assignment'
        
        bootstrap_datepicker('#task_due_date', text: task.due_date.strftime('%m/%d/%Y'))
      end
    end
  end
end
