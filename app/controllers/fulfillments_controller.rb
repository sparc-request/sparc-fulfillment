class FulfillmentsController < ApplicationController

  before_action :find_fulfillment, only: [:edit, :update]

  def new
    @line_item = LineItem.find(params[:line_item_id])
    @fulfillment = Fulfillment.new(line_item: @line_item)
  end

  def create
    @line_item = LineItem.find(fulfillment_params[:line_item_id])
    @fulfillment = Fulfillment.new(fulfillment_params.merge!({ creator: current_user }))
    if @fulfillment.valid?
      @fulfillment.save
      update_components
      flash[:success] = t(:flash_messages)[:fulfillment][:created]
    else
      @errors = @fulfillment.errors
    end
  end

  def edit
    @line_item = @fulfillment.line_item
  end

  def update
    @line_item = @fulfillment.line_item
    fulfillment_validation = Fulfillment.new(fulfillment_params, line_item_id: @fulfillment.line_item_id)
    if fulfillment_validation.valid?
      @fulfillment.update(fulfillment_params)
      update_components
      flash[:success] = t(:flash_messages)[:fulfillment][:updated]
    else
      @errors = fulfillment_validation.errors
    end
  end

  private

  def update_components
    if params[:fulfillment][:components]
      new_components = params[:fulfillment][:components].reject(&:empty?)
      old_components = @fulfillment.components.map(&:component)
      (new_components - old_components).each do |to_create|
        Component.create(component: to_create, composable_id: @fulfillment.id, composable_type: "Fulfillment")
      end
      (old_components - new_components).each do |to_destroy|
        @fulfillment.components.where(component: to_destroy).first.destroy
      end
      @fulfillment.reload
    end
  end

  def fulfillment_params
    params.require(:fulfillment).permit(:line_item_id, :fulfilled_at, :quantity, :performer_id)
  end

  def find_fulfillment
    @fulfillment = Fulfillment.where(id: params[:id]).first
  end
end