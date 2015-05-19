class LineItemsController < ApplicationController

  before_action :find_line_item, only: [:edit, :update]

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @line_item = LineItem.new(protocol: @protocol)
  end

  def create
    @line_item = LineItem.new(line_item_params)
    if @line_item.valid?
      @line_item.save
      flash[:success] = t(:line_item)[:flash_messages][:created]
    else
      @errors = @line_item.errors
    end
  end

  def edit
    @protocol = @line_item.protocol
  end

  def update
    persist_original_attributes_to_track_changes
    if @line_item.update_attributes(line_item_params)
      detect_changes_and_create_notes
      flash[:success] = t(:line_item)[:flash_messages][:updated]
    else
      @errors = @line_item.errors
    end
  end

  private

  def persist_original_attributes_to_track_changes
    @original_attributes = @line_item.attributes
  end

  def detect_changes_and_create_notes
    tracked_fields = [:quantity_requested, :service_id, :started_at]
    tracked_fields.each do |field|
      formatted_current = @original_attributes[field.to_s].to_s
      formatted_new = line_item_params[field.to_s]
      formatted_new = Time.strptime(line_item_params[field.to_s], "%m-%d-%Y").to_s if field == :started_at
      if formatted_current != formatted_new
        formatted_new = Time.strptime(line_item_params[field.to_s], "%m-%d-%Y").to_date.to_s if field == :started_at
        formatted_new = Service.find(line_item_params[field.to_s]).name if field == :service_id
        comment = t(:line_item)[:log_notes][field] + formatted_new
        @line_item.notes.create(kind: 'log', comment: comment, user: current_user)
      end
    end
  end

  def line_item_params
    params.require(:line_item).permit(:protocol_id, :quantity_requested, :service_id, :started_at)
  end

  def find_line_item
    @line_item = LineItem.find params[:id]
  end
end
