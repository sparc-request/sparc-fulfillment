class VisitsController < ApplicationController
  before_action :find_visit, only: [:update]

  def update
    if @visit.update_attributes(visit_params)
      @visit.update_procedures @visit.research_billing_qty
      @visit.update_procedures @visit.insurance_billing_qty
      flash[:success] = t(:visit)[:flash_messages][:updated]
    else
      @visit.errors.full_messages.each do |error|
        flash[:alert] = error
      end
    end
  end

  private

  def visit_params
    params.require(:visit).permit(:research_billing_qty, :insurance_billing_qty, :effort_billing_qty)
  end

  def find_visit
    @visit = Visit.find(params[:id])
  end
end
