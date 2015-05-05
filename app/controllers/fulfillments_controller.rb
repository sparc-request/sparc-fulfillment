class FulfillmentsController < ApplicationController

  before_action :find_fulfillment, only: [:edit, :update]

  def new
    @line_item = LineItem.find(params[:line_item_id])
    @fulfillment = Fulfillment.new(line_item: @line_item)
  end

  def create
    @fulfillment = Fulfillment.new(fulfillment_params)
    if @fulfillment.valid?
      @fulfillment.save
      flash[:success] = t(:flash_messages)[:fulfillment][:created]
    else
      @errors = @fulfillment.errors
    end
  end

  def edit
    @line_item = @fulfillment.line_item
  end

  def update
    @fulfillment = Fulfillment.find(params[:id])
    @line_item = @fulfillment.line_item
    fulfillment_validation = Fulfillment.new(fulfillment_params, line_item_id: @fulfillment.line_item_id)
    if fulfillment_validation.valid?
      @fulfillment.update(fulfillment_params)
      flash[:success] = t(:flash_messages)[:fulfillment][:updated]
    else
      @errors = fulfillment_validation.errors
    end
  end

  private

  def fulfillment_params
    params.require(:fulfillment).permit(:line_item_id, :fulfilled_at, :quantity, :performed_by)
  end

  def find_fulfillment
    @fulfillment = Fulfillment.where(id: params[:id]).first
  end
end