class NotesController < ApplicationController

  respond_to :json, :html

  before_action :find_notable, only: [:index]

  def index
    @notes = @notable.notes
    @notable_type = params[:note][:notable_type].downcase.to_sym
  end

  def new
    @note = Note.new(note_params)
  end

  def create
    @note = Note.create(note_params.merge!({ identity: current_identity })) if note_params[:comment].present? # don't create empty notes
  end

  private

  def note_params
    params.require(:note).permit(:notable_type, :notable_id, :comment, :kind)
  end

  def find_notable
    @notable = params[:note][:notable_type].constantize.find params[:note][:notable_id]
  end
end
