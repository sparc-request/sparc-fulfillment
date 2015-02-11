class NotesController < ApplicationController
  respond_to :json, :html

  def index
    @procedure = Procedure.find(params[:procedure_id])
    respond_to do |format|
      format.js { render }
      format.json do
        respond_with @procedure.notes
      end
    end
  end

  def new
    puts params.inspect
    @procedure = Procedure.find(params[:procedure_id])
  end

  def create
    puts params.inspect
    @procedure = Procedure.find(params[:procedure_id])
    @user = current_user
    @note = Note.create(procedure: @procedure, user: @user, user_name: @user.email, comment: params[:note])
  end

end
