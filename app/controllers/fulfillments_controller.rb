class FulfillmentsController < ApplicationController

  before_action :find_fulfillment, only: [:update]

  def update
    puts fulfillment_params
    @fulfillment.update_attributes(fulfillment_params)
    flash[:success] = t(:flash_messages)[:fulfillment][:updated]
  end

  private

  def fulfillment_params
    @fulfillment_params = params.require(:fulfillment).permit(:fulfilled_at, :quantity, :performed_by)
    @fulfillment_params[:fulfilled_at] = Time.at(@fulfillment_params[:fulfilled_at].to_i / 1000) if @fulfillment_params[:fulfilled_at]

    @fulfillment_params
  end

  def find_fulfillment
    @fulfillment = Fulfillment.where(id: params[:id]).first
  end
end