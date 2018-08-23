# Copyright © 2011-2018 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
    funding_source = @line_item.protocol.sparc_funding_source
    @fulfillment = Fulfillment.new(fulfillment_params.merge!({ creator: current_identity, service: service, service_name: service.name, service_cost: @line_item.cost(funding_source), funding_source: funding_source }))
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

  def destroy
    @fulfillment = Fulfillment.find(params[:id])
    @fulfillment.destroy
    respond_to do |format|
      format.js
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
          new_field = (field == :fulfilled_at ? Time.strptime(new_field, "%m/%d/%Y").to_date.to_s : new_field.to_s)
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
