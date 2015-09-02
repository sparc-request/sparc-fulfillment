class ArmsController < ApplicationController

  respond_to :json, :html
  before_action :find_arm, only: [:destroy, :refresh_vg_dropdown]

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @services = @protocol.line_items.map(&:service).uniq
    @arm = Arm.new(protocol: @protocol)
    @schedule_tab = params[:schedule_tab]
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
      @schedule_tab = params[:schedule_tab]
    else
      @errors = @arm_visit_group_creator.arm.errors
    end
  end

  def update
    @arm = Arm.find(params[:id])
    if @arm.update_attributes(arm_params)
      flash[:success] = t(:arm)[:flash_messages][:updated]
    else
      @errors = @arm.errors
    end
  end

  def destroy
    if Arm.where("protocol_id = ?", params[:protocol_id]).count == 1
      @arm.errors.add(:protocol, "must have at least one Arm.")
      @errors = @arm.errors
    elsif @arm.appointments.map{|a| a.has_completed_procedures?}.include?(true) # don't delete if arm has completed procedures
      @arm.errors.add(:arm, "'#{@arm.name}' has completed procedures and cannot be deleted")
      @errors = @arm.errors
    else
      @arm.delay.destroy
      flash.now[:alert] = t(:arm)[:deleted]
    end
  end

  def navigate_to_arm
    # Used in study schedule management for navigating to a arm.
    @protocol = Protocol.find(params[:protocol_id])
    @intended_action = params[:intended_action]
    @arm = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
  end

  private

  def arm_params
    params.require(:arm).permit(:protocol_id, :name, :visit_count, :subject_count)
  end

  def find_arm
    @arm = Arm.find(params[:id])
  end
end
