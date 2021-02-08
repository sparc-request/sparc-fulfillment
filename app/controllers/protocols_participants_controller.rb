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

class ProtocolsParticipantsController < ApplicationController
  before_action :find_protocol,               only: [:index, :show, :new, :create, :update, :destroy]
  before_action :find_protocols_participant,  only: [:show, :update, :destroy]

  def index
    respond_to do |format|
      format.json {
        @protocols_participants = @protocol.protocols_participants.search(params[:search])
        @total                  = @protocols_participants.length
        @protocols_participants = @protocols_participants.sorted(params[:sort], params[:order]).limit(params[:limit]).offset(params[:offset] || 0)
      }
    end
  end

  def show
    respond_to :html, :js
  end

  def new
    respond_to :js
  end

  def create
    respond_to :js
    @protocol.protocols_participants.create(participant_id: params[:participant_id])
    flash[:success] = t('protocols_participants.flash.updated')
  end

  def update
    respond_to :js
    @protocols_participant.update_attributes(protocols_participant_params)
    flash[:success] = t('protocols_participants.flash.updated')
  end

  def destroy
    respond_to :js
    @protocols_participant.destroy
    flash[:alert] = t('protocols_participants.flash.destroyed')
  end

  private

  def find_protocol
    @protocol = Protocol.find(params[:protocol_id])
  end

  def find_protocols_participant
    @protocols_participant = @protocol.protocols_participants.find(params[:id])
  end

  def protocols_participant_params
    params.require(:protocols_participant).permit(
      :arm_id,
      :external_id,
      :recruitment_source,
      :status
    )
  end
end