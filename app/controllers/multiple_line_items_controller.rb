# Copyright © 2011-2017 MUSC Foundation for Research Development~
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
    @protocol = Protocol.find params[:protocol_id]
    @services = @protocol.organization.inclusive_child_services(:per_participant)
    @page_hash = params[:page_hash]
    @schedule_tab = params[:schedule_tab]
  end

  def create_line_items
    # handles submission of the add line items form
    @service = Service.find(params[:add_service_id])

    if params[:add_service_arm_ids_and_pages] # if they selected arms, otherwise add error
      @schedule_tab = params[:schedule_tab]
      @arm_hash = {}
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
      @service.errors.add(:arms, "to add '#{@service.name}' to must be selected")
      @errors = @service.errors
    end
  end

  def edit_line_items
    # called to render modal to mass remove line items
    @protocol = Protocol.find params[:protocol_id]
    @all_services = @protocol.line_items.map(&:service).uniq
    @service = params[:service_id].present? ? Service.find(params[:service_id]) : @all_services.first
    @arms = @protocol.arms.select{ |arm| arm.line_items.detect{|li| li.service_id == @service.id} }
  end

  def destroy_line_items
    # handles submission of the remove line items form
    @service = Service.find(params[:remove_service_id])
    if params[:remove_service_arm_ids] # if they selected arms, otherwise add error
      @arm_ids = [params[:remove_service_arm_ids]].flatten
      line_items = @arm_ids.map{ |arm_id| LineItem.where("arm_id = #{arm_id} AND service_id = #{@service.id}").first } # get line_items to delete
      @line_item_ids = line_items.map(&:id)
      line_items.each do |li|
        #TODO this keeps you from deleting if the appointment has ANY completed procedure
        if li.visit_groups.map(&:appointments).flatten.map{|a| a.has_completed_procedures?}.include?(true) # don't delete if line_item has completed procedures
          @service.errors.add(:service, "'#{li.name}' on Arm '#{li.arm.name}' has completed procedures and cannot be deleted")
        end
      end
      unless @service.errors.present?
        line_items.each{ |li| li.destroy }
        flash.now[:success] = t(:services)[:deleted]
      else
        @errors = @service.errors
      end
    else
      @service.errors.add(:arms, "to remove '#{@service.name}' from must be selected")
      @errors = @service.errors
    end
  end
end
