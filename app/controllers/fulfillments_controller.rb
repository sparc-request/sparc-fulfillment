class FulfillmentsController < ApplicationController

  before_action :find_fulfillment, only: [:edit, :update]

  def new
    @line_item = LineItem.find(params[:line_item_id])
    @fulfillment = Fulfillment.new(line_item: @line_item)
    @component = Component.new(composable_id: @fulfillment.id, composable_type: 'Fulfillment')
  end

  def create
    @line_item = LineItem.find(fulfillment_params[:line_item_id])
    @fulfillment = Fulfillment.new(fulfillment_params, created_by: current_user)
    @component = Component.new(component: params[:fulfillment][:components][:component])
    if @fulfillment.valid? and @component.valid?
      @fulfillment.save
      @component.assign_attributes(composable_id: @fulfillment.id, composable_type: 'Fulfillment')
      @component.save
      flash[:success] = t(:flash_messages)[:fulfillment][:created]
    else
      @errors = @fulfillment.errors
      @component.errors.each{|e| @errors.add(e)}
    end
  end

  def edit
    @line_item = @fulfillment.line_item
  end

  def update
    @component = @fulfillment.component
    @line_item = @fulfillment.line_item
    fulfillment_validation = Fulfillment.new(fulfillment_params, line_item_id: @fulfillment.line_item_id)
    component_validation = Component.new(component: params[:fulfillment][:components][:component], composable_id: @fulfillment.id, composable_type: 'Fulfillment')
    if fulfillment_validation.valid? and component_validation.valid?
      @fulfillment.update(fulfillment_params)
      @component.update(component: params[:fulfillment][:components][:component])
      flash[:success] = t(:flash_messages)[:fulfillment][:updated]
    else
      @errors = fulfillment_validation.errors
      @component.errors.each{|e| @errors.add(e)}
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