class ProtocolsController < ApplicationController
  respond_to :json, :html
  def index
    status = params[:status] || 'Complete'
    @protocols = (status == 'All') ? Protocol.all : Protocol.where(status: status)
    respond_with @protocols
  end

  def show
    @protocol = Protocol.find_by(sparc_id: params[:id])
    @selected_arm = @protocol.arms.first
    @services = Service.all
    visit_groups = VisitGroup.all.map{ |vg| vg.arm_id == @selected_arm.id}
    @selected_visit_group = visit_groups.first
    respond_with @protocol.participants
  end

  def create_participant
    participant = Participant.create(protocol_id: params[:id], last_name: params[:last_name], first_name: params[:first_name], mrn: params[:mrn], status: params[:status], date_of_birth: params[:date_of_birth], gender: params[:gender], ethnicity: params[:ethnicity])
    participant.save
  end

  def change_arm
    @protocol = Protocol.find_by(sparc_id: params[:id])
    @selected_arm = @protocol.arms.find_by(id: params[:arm_id])
    @services = Service.all
    visit_groups = VisitGroup.all.map{ |vg| vg.arm_id == @selected_arm.id}
    @selected_visit_group = visit_groups.first
  end
end
