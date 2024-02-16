class ProcedureGroupsController < ApplicationController
  before_action :set_procedure_group, only: :update

  def update
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
