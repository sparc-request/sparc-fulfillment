class NotesController < ApplicationController

  respond_to :json, :html

  before_action :find_notable, only: [:index]

  def index
    @notes = @notable.notes
    @notable_id = params[:note][:notable_id]
    @notable_type = params[:note][:notable_type]
    @notable_sym = @notable_type.downcase.to_sym
  end

  def new
    @note = Note.new(note_params)
  end

  def create
    @note = Note.create(note_params.merge!({ identity: current_identity })) if note_params[:comment].present? # don't create empty notes
    appointment_note
    procedure_note
    if @note.notable_type == 'Fulfillment'
      fulfillment = Fulfillment.find(@note.notable_id)
      @line_item = LineItem.find(fulfillment.line_item_id)
    end
  end

  private

  def note_params
    params.require(:note).permit(:notable_type, :notable_id, :comment, :kind)
  end

  def find_notable
    @notable = params[:note][:notable_type].constantize.find params[:note][:notable_id]
  end

  def appointment_note
    if params[:note][:notable_type] == "Appointment"
      @appointment = Appointment.find(params[:note][:notable_id])
      @statuses = @appointment.appointment_statuses.map{|x| x.status}
    end
  end

  def procedure_note
    if params[:note][:notable_type] == "Procedure"
      @appointment = Procedure.find(params[:note][:notable_id]).appointment
      @statuses = @appointment.appointment_statuses.map{|x| x.status}
    end
  end
end
