class VisitGroupsController < ApplicationController
  respond_to :json, :html
  before_action :find_visit_group, only: [:update, :destroy]

  def new
    @current_page = params[:current_page] # the current page of the study schedule
    @protocol     = Protocol.find(params[:protocol_id])
    @visit_group  = VisitGroup.new()
    @schedule_tab = params[:schedule_tab]
    @arm = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
  end

  def create
    @visit_group                 = VisitGroup.new(visit_group_params)
    @arm                         = Arm.find(visit_group_params[:arm_id])
    @visit_group_visits_importer = VisitGroupVisitsImporter.new(@visit_group)
    @current_page                = params[:current_page]
    @schedule_tab                = params[:schedule_tab]
    @visit_groups                = @arm.visit_groups.paginate(page: @current_page)
    if @visit_group_visits_importer.save_and_create_dependents
      @arm.update_attributes(visit_count: @arm.visit_count + 1)
      @arm.reload
      flash.now[:success] = t(:visit_groups)[:created]
    else
      @errors = @visit_group.errors
    end
  end

  def update
    @arm = @visit_group.arm
    if @visit_group.update_attributes(visit_group_params)
      flash[:success] = t(:visit_groups)[:flash_messages][:updated]
    else
      @errors = @visit_group.errors
    end
  end

  def destroy
    @current_page = params[:page].to_i == 0 ? 1 : params[:page].to_i # can't be zero
    @arm          = @visit_group.arm
    @visit_groups = @arm.visit_groups.paginate(page: @current_page)
    @schedule_tab = params[:schedule_tab]
    if @arm.visit_count == 1
      @visit_group.errors.add(:arm, "must have at least one visit. Add another visit before deleting this one")
      @errors = @visit_group.errors
    elsif @visit_group.appointments.map{|a| a.has_completed_procedures?}.include?(true)
      @visit_group.errors.add(:visit_group, "'#{@visit_group.name}' has completed procedures and cannot be deleted")
      @errors = @visit_group.errors
    else
      @arm.update_attributes(visit_count: @arm.visit_count - 1)
      flash.now[:alert] = t(:visit_groups)[:deleted]
      @visit_group.destroy
    end
  end

  def navigate_to_visit_group
    # Used in study schedule management for navigating to a visit group, given an index of them by arm.
    @protocol = Protocol.find(params[:protocol_id])
    @intended_action = params[:intended_action]
    if params[:visit_group_id]
      @visit_group = VisitGroup.find(params[:visit_group_id])
      @arm = @visit_group.arm
    else
      @arm = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
      @visit_group = @arm.visit_groups.first
    end
  end

  private

  def visit_group_params
    params.require(:visit_group).permit(:arm_id, :position, :name, :day, :window_before, :window_after)
  end

  def find_visit_group
    @visit_group = VisitGroup.find(params[:id])
  end
end
