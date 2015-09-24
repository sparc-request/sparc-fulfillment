class FulfillmentsController < ApplicationController

  before_action :find_fulfillment, only: [:edit, :update]

  def index
    @line_item = LineItem.find(params[:line_item_id])
    respond_to do |format|
      format.js { render }
      format.json {
        @fulfillments = @line_item.fulfillments

        render
      }
    end
  end

  def new
    @line_item = LineItem.find(params[:line_item_id])
    @clinical_providers = ClinicalProvider.where(organization_id: @line_item.protocol.sub_service_request.organization_id)
    @fulfillment = Fulfillment.new(line_item: @line_item, performer: current_identity)
  end

  def create
    @line_item = LineItem.find(fulfillment_params[:line_item_id])
    service = @line_item.service
    funding_source = @line_item.protocol.funding_source
    @fulfillment = Fulfillment.new(fulfillment_params.merge!({ creator: current_identity, service: service, service_name: service.name, service_cost: service.cost(funding_source) }))
    if @fulfillment.valid?
      @fulfillment.save
      update_components_and_create_notes('create')
      flash[:success] = t(:fulfillment)[:flash_messages][:created]
    else
      @errors = @fulfillment.errors
    end
  end

  def edit
    @line_item = @fulfillment.line_item
    @clinical_providers = ClinicalProvider.where(organization_id: @line_item.protocol.sub_service_request.organization_id)
  end

  def update
    persist_original_attributes_to_track_changes
    @line_item = @fulfillment.line_item
    if @fulfillment.update_attributes(fulfillment_params)
      update_components_and_create_notes('update')
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
    tracked_fields = [:fulfilled_at, :account_number, :quantity, :performer_id]
    tracked_fields.each do |field|
      current_field = @original_attributes[field.to_s]
      new_field = fulfillment_params[field]
      unless new_field.blank?
        unless current_field.blank?
          current_field = (field == :fulfilled_at ? current_field.to_date.to_s : current_field.to_s)
          new_field = (field == :fulfilled_at ? Time.strptime(new_field, "%m-%d-%Y").to_date.to_s : new_field.to_s)
        end
        if current_field != new_field
          comment = t(:fulfillment)[:log_notes][field] + (field == :performer_id ? Identity.find(new_field).full_name : new_field.to_s)
          @fulfillment.notes.create(kind: 'log', comment: comment, identity: current_identity)
        end
      end
    end
  end

  def update_components_and_create_notes(action='update')
    if params[:fulfillment][:components]
      new_components = params[:fulfillment][:components].reject(&:empty?)
      old_components = @fulfillment.components.map(&:component)

      to_add = new_components - old_components
      to_add.each do |component|
        add = Component.new(component: component, composable_id: @fulfillment.id, composable_type: "Fulfillment")
        if add.valid?
          add.save
          if action == 'update'
            comment = "Component: #{component} added"
            @fulfillment.notes.create(kind: 'log', comment: comment, identity: current_identity)
          end
        end
      end

      to_remove = old_components - new_components
      to_remove.each do |component|
        remove = @fulfillment.components.where(component: component).first
        if remove
          remove.destroy
          if action == 'update'
            comment = "Component: #{component} removed"
            @fulfillment.notes.create(kind: 'log', comment: comment, identity: current_identity)
          end
        end
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
