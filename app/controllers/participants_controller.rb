class ParticipantsController < ApplicationController
  respond_to :json, :html

  def index
    @protocol = Protocol.find(params[:protocol_id])
    @participants = @protocol.participants
    respond_with @participants
  end

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.new(protocol_id: params[:protocol_id])
  end

  def show
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:id])
    @participant.build_appointments
  end

  def create
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.new(participant_params)
    @participant.protocol_id = @protocol.id
    if @participant.valid?
      @participant.save
      flash[:success] = t(:flash_messages)[:participant][:created]
    else
      @errors = @participant.errors
    end
  end

  def edit
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:id])
  end

  def update
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.new(participant_params)
    @participant.protocol_id = @protocol.id
    if @participant.valid?
      @participant = Participant.find(params[:id])
      @participant.update(participant_params)
      flash[:success] = t(:flash_messages)[:participant][:saved]
    else
      @errors = @participant.errors
    end
  end

  def destroy
    @protocol = Protocol.find(params[:protocol_id])
    Participant.destroy(params[:id])
    flash[:alert] = t(:flash_messages)[:participant][:removed]
  end

  def edit_arm
    def is_number?(string)
      Float(string) != nil rescue false
    end
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:participant_id])
    if is_number? params[:id]
      @arm = Arm.find(params[:id])
      @path = "/protocols/#{@protocol.id}/participants/#{@participant.id}/change_arm/#{@arm.id}"
    else
      @arm = Arm.new
      @path = "/protocols/#{@protocol.id}/participants/#{@participant.id}/change_arm"
    end
  end

  def update_arm
    @protocol = Protocol.find(params[:protocol_id])
    @participant = Participant.find(params[:participant_id])
    if params[:arm][:name] == ""
      @participant.arm = nil
    else
      @participant.arm = Arm.find( @protocol.arms.select{ |a| a.name == params[:arm][:name]}[0].id )
    end
    @participant.save
    flash[:success] = t(:flash_messages)[:participant][:arm_change]
  end

  def completed_appointments
    protocol = Protocol.find(params[:protocol_id])
    participant = Participant.find(params[:participant_id])
    @appointments = participant.appointments.where("completed_date IS NOT NULL")
  end

  private

  def participant_params
    params.require(:participant).permit(:last_name, :first_name, :mrn, :status, :date_of_birth, :gender, :ethnicity, :race, :address, :phone)
  end


end
