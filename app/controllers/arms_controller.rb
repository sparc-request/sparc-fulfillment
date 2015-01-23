class ArmsController < ApplicationController

  respond_to :json, :html

  def change
    @arm = Arm.find(params[:id])
    @visit_groups = @arm.visit_groups
    respond_with @visit_groups
  end

  def new
    @protocol = Protocol.find(params[:protocol_id])
    services_on_protocol = []
    @protocol.arms.each {|arm| services_on_protocol << arm.line_items.pluck(:service_id) }
    #the only services avaliable for select in the modal are the ones which are already on other arms of this protocol
    puts "*" * 80
    puts services_on_protocol
    services = services_on_protocol.flatten.uniq
    puts services.inspect
    @services = Service.find(services)
    @arm = Arm.new(protocol: @protocol)
  end

  def create
    @arm                      = Arm.new(arm_params)
    @arm_visit_group_creator  = ArmVisitGroupsImporter.new(@arm)
    services = params[:services] || []
    if @arm_visit_group_creator.save_and_create_dependents
      services.each do |service|
        line_item = LineItem.new(arm_id: @arm.id, service_id: service)
        importer = LineItemVisitsImporter.new(line_item)
        importer.save_and_create_dependents
      end
      flash.now[:success] = "Arm Created"
    else
      @errors = @arm_visit_group_creator.arm.errors
    end
  end

  def arm_params
    params.require(:arm).permit(:protocol_id, :name, :visit_count, :subject_count)
  end

  def destroy
    @arm = Arm.find(params[:id])
    if Arm.where("protocol_id = ?",params[:protocol_id]).count == 1
      flash.now[:alert] = "Protocols must have at least one arm. This arm cannot be deleted until another one is added"
    else
      @delete = true #this varaible is used in the coffescript logic to prevent the arm name from being removed from the dropdown
      @arm.delay.destroy
      flash.now[:alert] = "Arm Destroyed"
    end
  end
end
