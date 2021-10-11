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

module TaskHelper

  def format_task_reschedule(task_id)
    link_to icon('fas', 'calendar-alt'), edit_task_path(task_id), remote: true, class: 'btn btn-primary reschedule-task'
  end

  def format_task_checkbox task
    hidden_export_display = content_tag(:span, t("task.complete.#{task.complete?.to_s}"), class: 'd-none')
    checkbox = content_tag :div, nil, class: 'form-check' do
      raw([
        content_tag(:input, nil, type: 'checkbox', class: 'form-check-input complete-checkbox complete', id: "completeTask#{task.id}", task_id: task.id, checked: task.complete? ? "checked" : nil),
        content_tag(:label, nil, class: 'form-check-label', for: "completeTask#{task.id}")
      ].join(''))
    end

    raw([hidden_export_display, checkbox].join(''))
  end

  def format_task_type task
    task_type = task.assignable_type
    task_type += " (#{task.procedure.service_name})" if task_type == "Procedure"

    task_type
  end

  def format_task_protocol_id task
    case task.assignable_type
    when 'Procedure'
      task.procedure.protocol.srid
    else
      '-'
    end
  end

  def format_task_due_date task
    due_date = task.due_at
    if task.complete or (due_date - 7.days) > Time.now # task is complete or due_date is greater than 7 days away
      format_date(due_date)
    elsif due_date <= Time.now # due date has passed
      content_tag(:strong, class: "text-danger"){"#{format_date(due_date)} - #{t('task.past_due')}"}
    else # due date is within 7 days
      content_tag(:span, class: "text-warning strong"){"#{format_date(due_date)} - #{t('task.due_soon')} "}
    end
  end

  def format_task_org task
    case task.assignable_type
    when 'Procedure'
      core = task.procedure.core
      program = core.parent

      "#{program.name} / #{core.name}"
    else
      '-'
    end
  end
end
