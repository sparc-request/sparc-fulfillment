class FulfillmentsController < ApplicationController

  before_action :find_fulfillment, only: [:edit, :update]

  def new
    @line_item = LineItem.find(params[:line_item_id])
    @fulfillment = Fulfillment.new(line_item: @line_item, performer: current_user)
  end

  def create
    @line_item = LineItem.find(fulfillment_params[:line_item_id])
    @fulfillment = Fulfillment.new(fulfillment_params.merge!({ creator: current_user }))
    if @fulfillment.valid?
      @fulfillment.save
      update_components
      flash[:success] = t(:fulfillment)[:flash_messages][:created]
    else
      @errors = @fulfillment.errors
    end
  end

  def edit
    @line_item = @fulfillment.line_item
  end

  def update
    persist_original_attributes_to_track_changes
    @line_item = @fulfillment.line_item
    if @fulfillment.update_attributes(fulfillment_params)
      update_components
      detect_changes_and_create_notes
      flash[:success] = t(:fulfillment)[:flash_messages][:updated]
    else
      @errors = @fulfillment.errors
    end
  end

  private

  def persist_original_attributes_to_track_changes
    @original_attributes = @fulfillment.attributes
  end

  def detect_changes_and_create_notes
    tracked_fields = [:fulfilled_at, :quantity, :performer_id]
    tracked_fields.each do |field|
      formatted_current = @original_attributes[field.to_s].to_s
      formatted_new = fulfillment_params[field]
      formatted_new = Time.strptime(fulfillment_params[field], "%m-%d-%Y").to_s if field == :fulfilled_at
      if formatted_current != formatted_new
        formatted_new = Time.strptime(fulfillment_params[field], "%m-%d-%Y").to_date.to_s if field == :fulfilled_at
        formatted_new = User.find(fulfillment_params[field]).full_name if field == :performer_id
        comment = t(:fulfillment)[:log_notes][field] + formatted_new
        @fulfillment.notes.create(kind: 'log', comment: comment, user: current_user)
      end
    end
  end

  def update_components
    if params[:fulfillment][:components]
      @fulfillment.components.destroy_all
      new_components = params[:fulfillment][:components].reject(&:empty?)
      new_components.each do |to_create|
        Component.create(component: to_create, composable_id: @fulfillment.id, composable_type: "Fulfillment")
      end
      @fulfillment.reload
    end
  end

  def fulfillment_params
    params.require(:fulfillment).permit(:line_item_id, :fulfilled_at, :quantity, :performer_id)
  end

  def find_fulfillment
    @fulfillment = Fulfillment.find params[:id]
  end
end