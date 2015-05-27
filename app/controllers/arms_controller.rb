class ArmsController < ApplicationController

  respond_to :json, :html
  before_action :find_arm, only: [:destroy, :refresh_vg_dropdown]

  def new
    @protocol = Protocol.find(params[:protocol_id])
    services_on_protocol = []
    @protocol.arms.each {|arm| services_on_protocol << arm.line_items.pluck(:service_id) }
    #the only services avaliable for select in the modal are the ones which are already on other arms of this protocol
    services = services_on_protocol.flatten.uniq
    @services = Service.find(services)
    @arm = Arm.new(protocol: @protocol)
  end

  def create
    @arm                      = Arm.new(arm_params)
    @arm_visit_group_creator  = ArmVisitGroupsImporter.new(@arm)
    services = params[:services] || []
    if @arm_visit_group_creator.save_and_create_dependents
      services.each do |service|
        line_item = LineItem.new(protocol_id: @arm.protocol_id, arm_id: @arm.id, service_id: service, subject_count: @arm.subject_count)
        importer = LineItemVisitsImporter.new(line_item)
        importer.save_and_create_dependents
      end
      flash.now[:success] = t(:arm)[:created]
    else
      @errors = @arm_visit_group_creator.arm.errors
    end
  end

  def destroy
    if Arm.where("protocol_id = ?", params[:protocol_id]).count == 1
      flash.now[:alert] = t(:arm)[:not_deleted]
    else
      @delete = true #this variable is used in the coffescript logic to prevent the arm name from being removed from the dropdown
      @arm.delay.destroy
      flash.now[:alert] = t(:arm)[:deleted]
    end
  end

  private

  def arm_params
    params.require(:arm).permit(:protocol_id, :name, :visit_count, :subject_count)
  end

  def find_arm
    @arm = Arm.find(params[:id])
  end
end
