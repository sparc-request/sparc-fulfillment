class AppointmentsController < ApplicationController

  respond_to :json, :html

  #### BEGIN CUSTOM APPOINTMENTS ####

  def new
    @appointment = CustomAppointment.new(custom_appointment_params)
    @note = @appointment.notes.new(kind: 'reason')
  end

  def create
    ##### TODO, figure out a way to not have to use base model
    @appointment = Appointment.new(custom_appointment_params)

    if @appointment.valid?
      @appointment.save
      @appointment.update_attribute(:type, "CustomAppointment")
    end
  end

  #### END CUSTOM APPOINTMENTS ####

  def show
    @appointment = Appointment.find params[:id]
    @statuses = @appointment.appointment_statuses.map{|x| x.status}
    if @appointment.procedures.empty?
      @appointment.initialize_procedures
    end
  end

  def completed_appointments
    participant = Participant.find(params[:participant_id])
    @appointments = participant.appointments.completed
    respond_with @appointments
  end

  def update
    @appointment = Appointment.find params[:id]
    @field = params[:field]

    @appointment.update_attributes(appointment_params)
  end

  def update_statuses
    @appointment = Appointment.find params[:appointment_id]
    new_statuses = params[:statuses]
    @appointment.appointment_statuses.destroy_all

    if params[:statuses].present?
      new_statuses.each do |status|
        @appointment.appointment_statuses.create(status: status)
      end
    end

    render nothing: true
  end

  private

  def show_time in_time
    in_time.blank? ? Time.now : in_time
  end

  def appointment_params
    params.require(:appointment).permit(:contents, :start_date, :completed_date)
  end

  def custom_appointment_params
    params.require(:custom_appointment)
          .permit(:arm_id, :participant_id, :name, :position,
                 notes_attributes: [:comment, :kind, :identity_id, :reason])
  end
end
