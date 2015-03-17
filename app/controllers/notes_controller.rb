class NotesController < ApplicationController

  respond_to :json, :html

  before_action :find_notable, only: [:index]

  def index
    @notes = @notable.notes
  end

  def new
    @note = Note.new(note_params)
  end

  def create
    @note = Note.create(note_params.merge!({ user: current_user }))
  end

  private

  def note_params
    params.require(:note).permit(:notable_type, :notable_id, :comment, :kind)
  end

  def find_notable
    @notable = params[:notable][:type].constantize.find params[:notable][:id]
  end
end
