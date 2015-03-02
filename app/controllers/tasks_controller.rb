class TasksController < ApplicationController
  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        @tasks = Task.all

        render
      end
    end
  end
end