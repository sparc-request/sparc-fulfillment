class ProtocolsController < ApplicationController
  respond_to :json, :html
  def index
    @protocols = Protocol.all
    respond_with @protocols
  end

  def show
    @protocol = Protocol.find_by_sparc_id(params[:id])
    @selected_arm = @protocol.arms.first
    @services = Service.all
    respond_with @protocol.participants
  end

  def create_participant
    participant = Participant.create(protocol_id: params[:id], last_name: params[:last_name], first_name: params[:first_name], mrn: params[:mrn], status: params[:status], date_of_birth: params[:date_of_birth], gender: params[:gender], ethnicity: params[:ethnicity])
    participant.save
  end

end
