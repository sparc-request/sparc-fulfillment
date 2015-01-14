class VisitGroupsController < ApplicationController
  respond_to :json, :html

  def new
    @current_page = params[:page] # the current page of the service calendar
    @arm = Arm.find(params[:arm_id])
    @visit_group = VisitGroup.new(arm_id: params[:arm_id])
    @calendar_tab = params[:calendar_tab]
  end

  def create
    @visit_group                  = VisitGroup.new(visit_group_params)
    @visit_group_visits_importer  = VisitGroupVisitsImporter.new(@visit_group)
    @arm =  Arm.find(visit_group_params[:arm_id])
    @current_page = params[:current_page]
    @calendar_tab = params[:calendar_tab]
    @visit_groups = @arm.visit_groups.paginate(page: @current_page)
    if @visit_group_visits_importer.save_and_create_dependents
      @arm.update_attributes(visit_count: @arm.visit_count + 1)
      flash.now[:success] = "Visit Created"
    else
      @errors = @visit_group.errors
    end
  end

  def visit_group_params
    params.require(:visit_group).permit(:arm_id, :position, :name, :day, :window_before, :window_after)
  end

  def destroy
    @arm = Arm.find(params[:arm_id])
    @current_page = params[:page]
    @visit_group = VisitGroup.find(params[:id])
    if @arm.visit_count == 1
      flash.now[:alert] = "Arms must have at least one visit. Add another visit before deleting this one"
    else
      @arm.update_attributes(visit_count: @arm.visit_count - 1)
      @delete = true #used in the coffeescript to determine whether or not to remove the display of the visit
      flash.now[:alert] = "Visit Destroyed"
      @visit_group.destroy
    end
  end

end
