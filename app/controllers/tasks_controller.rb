class TasksController < ApplicationController
  respond_to :json, :html
  require 'json'

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        @tasks = Task.where(is_complete: nil)

        render
      end
    end
  end

  def new
    @task = Task.new()
  end

  def create
    @task = Task.new(task_params.merge!({ user: current_user}))
    if @task.valid?
      @task.save
      flash[:success] = t(:flash_messages)[:task][:created]
    else
      @errors = @task.errors
    end
  end

  def update
    @task = Task.find(params[:id])
    if @task.update_attributes(task_params)
      flash[:success] = t(:flash_messages)[:task][:updated]
    end
  end

  def task_reschedule
    @task = Task.find(params[:id])
  end

  def completed_tasks
    @completed_tasks = Task.where("is_complete")
  end

  def incomplete_tasks
    @incompleted_tasks = params[:incompletes]
    if not @incompleted_tasks.nil?
      @incompleted_tasks.each do|task|
        task = Task.find(task)
        task.update_attributes(is_complete: nil)
      end
      flash[:success] = t(:flash_messages)[:task][:incompleted]
    end
  end

  private

  def task_params
    params.require(:task).permit(:is_complete, :participant_name, :due_date, :protocol_id, :visit_name,
                                  :arm_name, :task, :assignee_id, :task_type)
  end
end
