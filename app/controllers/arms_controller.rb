# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

class ArmsController < ApplicationController

  respond_to :json, :html
  before_action :find_arm, only: [:destroy, :refresh_vg_dropdown]

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @services = @protocol.line_items.map(&:service).uniq
    @arm = Arm.new(protocol: @protocol)
    @schedule_tab = params[:schedule_tab]
  end

  def create
    @arm                      = Arm.new(arm_params)
    @arm_visit_group_creator  = ArmVisitGroupsImporter.new(@arm)
    services = params[:services] || []
    if @arm_visit_group_creator.save_and_create_dependents
      services.each do |service|
        line_item = LineItem.new(protocol_id: @arm.protocol_id, arm_id: @arm.id, service_id: service, subject_count: @arm.subject_count)
        importer = LineItemVisitsImporter.new(line_item)
        importer.save_and_create_dependents
      end
      flash.now[:success] = t(:arm)[:created]
      @schedule_tab = params[:schedule_tab]
    else
      @errors = @arm_visit_group_creator.arm.errors
    end
  end

  def update
    @arm = Arm.find(params[:id])
    if @arm.update_attributes(arm_params)
      flash[:success] = t(:arm)[:flash_messages][:updated]
    else
      @errors = @arm.errors
    end
  end

  def destroy
    if Arm.where("protocol_id = ?", params[:protocol_id]).count == 1
      @arm.errors.add(:protocol, "must have at least one Arm.")
      @errors = @arm.errors
    elsif @arm.appointments.map{|a| a.has_completed_procedures?}.include?(true) # don't delete if arm has completed procedures
      @arm.errors.add(:arm, "'#{@arm.name}' has completed procedures and cannot be deleted")
      @errors = @arm.errors
    else
      @arm.destroy_later
      flash.now[:alert] = t(:arm)[:deleted]
    end
  end

  def navigate_to_arm
    # Used in study schedule management for navigating to a arm.
    @protocol = Protocol.find(params[:protocol_id])
    @intended_action = params[:intended_action]
    @arm = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
  end

  private

  def arm_params
    params.require(:arm).permit(:protocol_id, :name, :visit_count, :subject_count)
  end

  def find_arm
    @arm = Arm.find(params[:id])
  end
end
