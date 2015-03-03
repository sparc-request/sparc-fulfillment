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
    if params[:is_complete]
      @task.update_attributes(is_complete: true)
      flash[:success] = t(:flash_messages)[:task][:completed] if @task.valid?
    end
  end
end