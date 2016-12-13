# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

class ProtocolsController < ApplicationController

  before_action :find_protocol, only: [:show]
  before_action :authorize_protocol, only: [:show]

  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        @protocols = current_identity.protocols

        if params[:status].present? && params[:status] != 'all'
          @protocols = @protocols.select { |protocol| protocol.status == params[:status] }
        end

        render
      end
    end
  end

  def show
    @page_details = @protocol.srid
    @services = @protocol.organization.inclusive_child_services(:per_participant)
    @services_present = @services.present? || @protocol.line_items.map{ |line_item| !line_item.one_time_fee }.any?
    @current_protocol_tab = get_current_protocol_tab

    @page = 1

    gon.push({ protocol_id: @protocol.id })
  end

  private

  def find_protocol
    unless @protocol = Protocol.where(id: params[:id]).first
      flash[:alert] = t(:protocol)[:flash_messages][:not_found]
      redirect_to root_path
    end
  end

  def get_current_protocol_tab
    cookies['active-protocol-tab'.to_sym] ? cookies['active-protocol-tab'.to_sym] : (@services_present ? "study_schedule" : "study_level_activities")
  end
end
