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

class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception, prepend: true

  before_action :authenticate_identity!
  before_action :establish_bradcrumber
  before_action :set_highlighted_link
  before_action :push_user_to_gon, if: :identity_signed_in?

  around_action :set_time_zone, if: :identity_signed_in?

  def set_time_zone(&block)
    time_zone = current_identity.time_zone
    Time.use_zone(time_zone, &block)
  end

  def authorize_protocol
    unless current_identity.protocols.exists?(@protocol.id)
      flash[:alert] = t(:protocol)[:flash_messages][:unauthorized]
      redirect_to root_path
    end
  end

  def set_highlighted_link  # default value, override inside controllers
    @highlighted_link ||= ''
  end

  def push_user_to_gon
    gon.push({current_identity_id: current_identity.id})
  end

  def set_appointment_style
    @appointment_style = session[:appointment_style] || "grouped"
  end

  def sanitize_date(date)
    return Date.strptime(date, '%m/%d/%Y').to_s rescue Date.strptime(date, '%Y-%m-%d').to_s rescue ""
  end

  private

  def establish_bradcrumber
    if !session[:breadcrumbs] || !session[:breadcrumbs].is_a?(Breadcrumber)
      session[:breadcrumbs] = Breadcrumber.new
    else
      session[:breadcrumbs].clear
    end
  end
end
