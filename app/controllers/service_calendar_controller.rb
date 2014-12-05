class ServiceCalendarController < ApplicationController
  respond_to :json, :html

  def line_items
    @protocol = Protocol.find params[:protocol_id]
    @line_items = LineItem.where(arm_id: params[:arm_id]).order(:core)

    respond_with @line_items
  end

  def visits
    @protocol = Protocol.find params[:protocol_id]
    @line_items = LineItem.includes(:visits).where(arm_id: params[:arm_id]).order(:core)
    @visits = @line_items.map { |li| li.visits }

    respond_with @visits.to_json(include: :visit_group)
  end
end
