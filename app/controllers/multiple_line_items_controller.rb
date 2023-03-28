# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class MultipleLineItemsController < ApplicationController
  respond_to :json, :html
  #this controller exists in order to separate the mass creation of line items
  #from single line item creation and deletion which will happen on the study schedule

  def new_line_items
    # called to render modal to mass create line items
    @protocol = Protocol.find(params[:protocol_id])
    @services = @protocol.organization.inclusive_child_services(:per_participant)
    @page_hash = params[:page_hash]
    @schedule_tab = params[:schedule_tab]
    @first_line_item = params[:first_line_item] || false
  end

  def create_line_items
    # handles submission of the add line items form
    @service = Service.find(params[:add_service_id])
    @core = @service.organization
    @schedule_tab = params[:schedule_tab]
    @arm_hash = {}
    @first_line_item = params[:first_line_item] == 'true'

    if @first_line_item # if creating first line item on protocol
      @protocol = Protocol.find(params[:protocol_id])
      
      @arm                      = Arm.new(protocol: @protocol, name: "Screening Phase", visit_count: 1, subject_count: 1)
      @arm_visit_group_creator  = ArmVisitGroupsImporter.new(@arm)

      if @arm_visit_group_creator.save_and_create_dependents
        line_item = LineItem.new(protocol_id: @arm.protocol_id, arm_id: @arm.id, service_id: @service.id, subject_count: @arm.subject_count)
        importer = LineItemVisitsImporter.new(line_item)
        importer.save_and_create_dependents
      end

      # get pppv services and set tab for the sake of rendering the tab now that services are present
      @tab = 'study_schedule'
      cookies['active-protocol-tab'.to_sym] = @tab
      @has_pppv_services = @protocol.organization.has_per_patient_per_visit_services? || @protocol.line_items.joins(:service).where(services: { one_time_fee: false }).any?
    elsif params[:add_service_arm_ids_and_pages] # if they selected arms, otherwise add error
      params[:add_service_arm_ids_and_pages].each do |set|
        arm_id, page = set.split
        arm = Arm.find(arm_id)

        unless arm.line_items.map(&:service_id).include? @service.id # unless service is already on one of the selected arms
          line_item = LineItem.new(protocol_id: arm.protocol_id, arm_id: arm_id, service_id: @service.id, subject_count: arm.subject_count)
          importer = LineItemVisitsImporter.new(line_item)
          importer.save_and_create_dependents
          @arm_hash[arm_id] = {page: page, line_item: line_item}
        end
      end

      flash.now[:success] = t(:services)[:created]
    else
      @service.errors.add(:arms, t('constants.cant_be_blank'))
      @errors = @service.errors
    end
  end

  def edit_line_items
    # called to render modal to mass remove line items
    protocol = Protocol.find(params[:protocol_id])
    @line_items = protocol.line_items.select{|line_item| !line_item.one_time_fee && line_item.arm.procedures.where(service_id: line_item.service_id).touched.empty? }
  end

  def destroy_line_items
    # handles submission of the remove line items form
    @line_items = LineItem.where(id: params[:line_item_ids]).destroy_all
    if !@line_items.empty?
      flash.now[:success] = t(:services)[:deleted]
    else
      @error = t('constants.cant_be_blank')
    end
  end
end
