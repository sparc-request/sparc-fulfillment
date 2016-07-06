class LineItemsController < ApplicationController

  before_action :find_line_item, only: [:edit, :update]

  def index
    respond_to do |format|
      format.json {
        @protocol = Protocol.find(params[:protocol_id])
        @line_items = @protocol.one_time_fee_line_items

        render
      }
    end
  end

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @line_item = LineItem.new(protocol: @protocol)
  end

  def create
    @line_item = LineItem.new(line_item_params)
    
    if @line_item.valid?
      @line_item.quantity_type = @line_item.service.current_effective_pricing_map.quantity_type
      @line_item.save
      flash[:success] = t(:line_item)[:flash_messages][:created]
    else
      @errors = @line_item.errors
    end
  end

  def edit
    @protocol = @line_item.protocol
    @otf = @line_item.one_time_fee
  end

  def update
    @otf = @line_item.one_time_fee
    persist_original_attributes_to_track_changes if @otf
    if @line_item.update_attributes(line_item_params)
      @line_item.update_columns(quantity_type: @line_item.service.current_effective_pricing_map.quantity_type)
      if @otf
        detect_changes_and_create_notes # study level charges needs notes for changes
      else
        update_line_item_procedures_service # study schedule line item service change
      end
      flash[:success] = t(:line_item)[:flash_messages][:updated]
    else
      @errors = @line_item.errors
    end
  end

  def destroy
    @line_item = LineItem.find(params[:id])
    if @line_item.fulfillments.empty?
      @line_item.destroy
      flash[:success] = t(:line_item)[:flash_messages][:deleted]
    else
      flash[:alert] = t(:line_item)[:flash_messages][:not_deleted]
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
          new_field = (field == "started_at" ? Time.strptime(new_field, "%m/%d/%Y").to_date.to_s : new_field)
        end
        if current_field != new_field
          comment = t(:line_item)[:log_notes][field.to_sym] + (field == "service_id" ? Service.find(new_field).name : new_field.to_s)
          @line_item.notes.create(kind: 'log', comment: comment, identity: current_identity)
        end
      end
    end
  end

  def update_line_item_procedures_service
    # Need to change any procedures that haven't been completed to the new service
    service = @line_item.service
    service_name = service.name
    @line_item.visits.each do |v|
      v.procedures.select{ |p| not(p.appt_started? or p.complete?) }.each do |p|
        p.update_attributes(service_id: service.id, service_name: service_name)
      end
    end
  end

  def line_item_params
    params.require(:line_item).permit(:protocol_id, :quantity_requested, :service_id, :started_at, :account_number, :contact_name)
  end

  def find_line_item
    @line_item = LineItem.find params[:id]
  end

end
