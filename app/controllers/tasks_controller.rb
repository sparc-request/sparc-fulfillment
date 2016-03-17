class TasksController < ApplicationController

  before_action :find_task, only: [:show, :update, :task_reschedule]

  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do

        @tasks = scoped_tasks

        render
      end
    end
  end

  def show
    @partial = ["show", @task.assignable_type.downcase, "task"].join("_")
  end

  def new
    respond_to do |format|
      format.js {
        @task = Task.new
        @clinical_providers = ClinicalProvider.where(organization_id: current_identity.protocols.map{|p| p.sub_service_request.organization_id }).index_by {|cp| cp[:identity_id]}.values
      }
    end
  end

  def create
    task_parameters = task_params.to_h.except("notes")
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
    else
      @errors = @task.errors
    end
  end

  def update
    if @task.update_attributes(task_params)
      flash[:success] = t(:task)[:flash_messages][:updated]
    end
  end

  def task_reschedule
    # this pops up the modal to change the date for a task
  end

  private

  def create_procedure_note?
    task_params[:notes] && task_params[:notes][:notable_type] == "Procedure"
  end

  def create_note
    if create_procedure_note?
      @appointment = @procedure.present? ? @procedure.appointment : Procedure.find(task_params[:notes][:notable_id]).appointment
      @statuses = @appointment.appointment_statuses.map{|x| x.status}
      
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
    params.
      require(:task).
      permit(:complete, :body, :due_at, :assignee_id, :assignable_type, :assignable_id, notes: [:kind, :comment, :notable_type, :notable_id])
  end

  def scoped_tasks
    if params[:scope].present?
      if (params[:scope] == 'mine') || (params[:scope] == 'incomplete')
        return Task.mine(current_identity)
      else
        return Task.send(params[:scope])
      end
    else
      return Task.mine(current_identity)
    end
  end
end
