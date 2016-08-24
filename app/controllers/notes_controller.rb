class NotesController < ApplicationController

  respond_to :json, :html

  before_action :find_notable, only: [:index, :create]

  def index
    @notes = @notable.notes
  end

  def new
    @note = Note.new(note_params)
  end

  def create
    if note_params[:comment].present? # don't create empty notes
      @note = Note.create(note_params.merge!({ identity: current_identity }))
      @selector = "#{@note.unique_selector}_notes"
    end
    @notes = @notable.notes
  end

  private

  def note_params
    params.require(:note).permit(:notable_type, :notable_id, :comment, :kind)
  end

  def find_notable
    @notable_id = params[:note][:notable_id]
    @notable_type = params[:note][:notable_type]
    @notable = params[:note][:notable_type].constantize.find(@notable_id)
  end
end
