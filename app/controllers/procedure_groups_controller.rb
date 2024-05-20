class ProcedureGroupsController < ApplicationController
  before_action :set_procedure_group, only: :update

  def update
    @procedure_group.set_start_time(params[:procedure_group][:start_time]) if params[:procedure_group][:start_time].present?
    @procedure_group.set_end_time(params[:procedure_group][:end_time]) if params[:procedure_group][:end_time].present?

    if @procedure_group.update(procedure_group_params)
      flash[:success] = t('procedure_groups.flash_messages.updated')
      respond_to :js
    else
      @errors = @procedure_group.errors.full_messages
    end
  end

  private
    def set_procedure_group
      @procedure_group = ProcedureGroup.find(params[:id])
    end

    def procedure_group_params
      params.require(:procedure_group).permit(:start_time, :end_time)
    end
end
