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
    tracked_fields = ["quantity_requested", "service_id", "started_at"]
    tracked_fields.each do |field|
      current_field = @original_attributes[field]
      new_field = line_item_params[field]
      unless new_field.blank?
        unless current_field.blank?
          current_field = (field == "started_at" ? current_field.to_date.to_s : current_field.to_s)
          new_field = (field == "started_at" ? Time.strptime(new_field, "%m-%d-%Y").to_date.to_s : new_field)
        end
        if current_field != new_field
          comment = t(:line_item)[:log_notes][field.to_sym] + (field == "service_id" ? Service.find(new_field).name : new_field.to_s)
          @line_item.notes.create(kind: 'log', comment: comment, identity: current_identity)
        end
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
