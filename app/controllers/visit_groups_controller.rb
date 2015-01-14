class VisitGroupsController < ApplicationController
  respond_to :json, :html

  def new
    @arm = Arm.find(params[:arm_id])
    @visit_group = VisitGroup.new(arm_id: params[:arm_id])
  end

  def create
    @visit_group                  = VisitGroup.new(visit_group_params)
    @visit_group_visits_importer  = VisitGroupVisitsImporter.new(@visit_group)

    if @visit_group_visits_importer.save_and_create_dependents
      flash.now[:success] = "Visit Created"
    else
      @errors = @visit_group.errors
    end
  end

  def visit_group_params
    params.require(:visit_group).permit(:arm_id, :position, :name, :day, :window_before, :window_after)
  end

  def destroy
    if Arm.find(params[:arm_id]).visit_groups.count == 1
      flash.now[:alert] = "Arms must have at least one visit. Add another visit before deleting this one"
    else
      @delete = true #used in the coffeescript to determine whether or not to remove the display of the visit
      flash.now[:alert] = "Visit Destroyed"
      VisitGroup.destroy(params[:id])
    end
  end

end
