class NotesController < ApplicationController
  respond_to :json, :html

  def index
    @procedure = Procedure.find(params[:procedure_id])
  end

  def new
    @procedure = Procedure.find(params[:procedure_id])
    @note = Note.new
  end

  def create
    unless params[:note][:comment].length == 0
      @procedure = Procedure.find(params[:procedure_id])
      @note = Note.create(procedure: @procedure, user_id: current_user.id, user_name: current_user.email, comment: params[:note][:comment])
    end
  end

end
