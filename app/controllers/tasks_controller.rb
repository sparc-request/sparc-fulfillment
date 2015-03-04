class TasksController < ApplicationController
  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        @tasks = Task.where(is_complete: nil)

        render
      end
    end
  end

  def update
    @task = Task.find(params[:id])
    if @task.update_attributes(task_params)
      flash[:success] = t(:flash_messages)[:task][:updated]
    end
  end

  private

  def task_params
    params.require(:task).permit(:is_complete, :participant_name)
  end
end