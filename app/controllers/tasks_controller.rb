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

class TasksController < ApplicationController
  before_action :find_task, only: [:show, :update, :edit]
  before_action :set_appointment_style, only: [:create]

  respond_to :json, :html

  def index
    @task_id = params[:id]
    @limit = params[:limit] || 25

    respond_to do |format|
      format.html
      format.json {
        @tasks = scoped_tasks
      }
      format.csv {
        send_data Task.to_csv(scoped_tasks), filename: "cwf_tasks.csv"
      }
    end
  end

  def show
    @partial = ["show", @task.assignable_type.downcase, "task"].join("_")
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    respond_to do |format|
      format.js {
        @task = Task.new
        @clinical_providers = Identity.joins(:clinical_providers).where('clinical_providers.organization_id': current_identity.protocols_organizations_ids).order('identities.last_name').distinct
      }
    end
  end

  def create
    respond_to :js

    task_parameters = task_params.except("notes")
    if task_params[:notes]
      task_parameters[:body] = task_params[:notes][:comment]
    end
    @task = Task.new(task_parameters.merge!({ identity: current_identity}))
    if @task.valid?
      @task.save
      if task_params[:assignable_type] == "Procedure"
        @procedure = Procedure.find(task_params[:assignable_id])
        @procedure.update_attributes(status: "follow_up") if @procedure.unstarted?
      end
      create_note
      flash[:success] = t(:task)[:flash_messages][:created]
      email_identity = Identity.find(task_params[:assignee_id])
      TaskMailer.task_confirmation(email_identity, @task).deliver_now
    else
      @errors = @task.errors
    end
  end

  def update
    respond_to :js
    if @task.update_attributes(task_params)
      flash[:success] = t(:task)[:flash_messages][:updated]
    else
      @errors = @task.errors
    end
  end

  def edit
    respond_to :js
  end

  private

  def create_procedure_note?
    task_params[:notes] && task_params[:notes][:notable_type] == "Procedure"
  end

  def create_note
    if create_procedure_note?
      @appointment = @procedure.present? ? @procedure.appointment : Procedure.find(task_params[:notes][:notable_id]).appointment
      @statuses = @appointment.appointment_statuses.pluck(:status)

      notes_params = task_params[:notes]
      notes_params[:identity] = current_identity

      Note.create(notes_params)
    end
  end

  def to_boolean string
    if string == 'true'
      return true
    elsif string == 'false'
      return false
    end
  end

  def find_task
    @task = Task.find(params[:id])
  end

  def task_params
    # sanitize date params
    params[:task][:due_at] = sanitize_date(params[:task][:due_at]) if params[:task][:due_at]

    params.require(:task).permit(
      :complete, :body, :due_at, :assignee_id, :assignable_type, :assignable_id,
      notes: [:kind, :comment, :notable_type, :notable_id])
  end

  def scoped_tasks
    if !params[:scope] || params[:scope] == 'mine'
      if params[:status] == "complete"
        tasks = Task.json_info.mine(current_identity).complete
      else
        tasks = Task.json_info.mine(current_identity).incomplete
      end
    else
      if params[:status] == "complete"
        tasks = Task.json_info.complete
      else
        tasks = Task.json_info.incomplete
      end
    end

    @total = tasks.count
    case params[:sort]
    when "identity_name"
      custom_sorted = tasks.includes(:identity).sort_by{|task| task.identity.full_name}
    when "assignee_name"
      custom_sorted = tasks.includes(:assignee).sort_by{|task| task.assignee.full_name}
    when "protocol_id"
      custom_sorted = tasks.includes(procedure: [protocol: [:sub_service_request]]).sort_by{|task| (task.procedure ? task.procedure.protocol.srid : '')}
    when "organization"
      custom_sorted = tasks.includes(procedure: [protocol: [:sub_service_request]]).sort_by{|task| (task.procedure ? "#{task.procedure.core} #{task.procedure.core.parent}" : '')}
    end

    if !custom_sorted.nil?
      custom_sorted.reverse! if params[:order] == "desc"
      custom_sorted.last(@total - params[:offset].to_i).first(params[:limit].to_i)
    else
      tasks.sorted(params[:sort], params[:order]).limit(params[:limit]).offset(params[:offset] || 0)
    end
  end

  def set_highlighted_link
    @highlighted_link ||= 'tasks'
  end
end
