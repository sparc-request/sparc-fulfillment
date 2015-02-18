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
      user = current_user
      @note = Note.create(procedure: @procedure, user_id: user.id, user_name: user.first_name+' '+user.last_name, comment: params[:note][:comment])
    end
  end

end
