# Copyright © 2011-2020 MUSC Foundation for Research Development~
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
  before_action :find_protocol,       only: [:show, :refresh_tab]
  before_action :authorize_protocol,  only: [:show], unless: proc { |controller| controller.request.format.json? }

  def index
    respond_to do |format|
      format.html {
        session[:breadcrumbs].clear.set_base(:requests, root_url)
        if cookies['protocols.bs.table.columns'].blank? && !ENV['DEFAULT_HOME_COLUMNS'].blank?
          cookies['protocols.bs.table.columns'] = {
            value:    ENV['DEFAULT_HOME_COLUMNS'].split(',').to_json,
            expires:  2.hours.from_now
          }
        end
      }
      format.json {
        @protocols  = current_identity.protocols_full.search(params[:search]).with_status(params[:status])
        @total      = @protocols.length
        @protocols  = @protocols.sorted(params[:sort], params[:order]).limit(params[:limit]).offset(params[:offset] || 0).eager_load(:pi)
      }
      format.js
    end
  end

  def show
    respond_to :html
    gon.push({ protocol_id: @protocol.id })
    session[:breadcrumbs].clear.set_base(:requests, root_url).add_crumbs([
      { label: helpers.protocol_label(@protocol) },
      { label: helpers.request_label(@protocol) }
    ])
    get_current_protocol_tab
  end

  def refresh_tab
    respond_to :js
    @tab = params[:tab]
  end

  private

  def find_protocol
    unless @protocol = Protocol.where(id: params[:id]).first
      flash[:alert] = t(:protocol)[:flash_messages][:not_found]
      redirect_to root_path
    end
  end

  def get_current_protocol_tab
    @tab = cookies['active-protocol-tab'.to_sym] ? cookies['active-protocol-tab'.to_sym] : (@services_present ? "study_schedule" : "study_level_activities")
  end
end
