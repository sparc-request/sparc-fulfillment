class ProtocolsController < ApplicationController
  before_action :find_protocol, only: [:show]
  before_action -> { authorize_identity @protocol.id }, only: [:show]
  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        @protocols = current_identity.protocols

        if params[:status].present? && params[:status] != 'All'
          @protocols = @protocols.select { |protocol| protocol.status == params[:status] }
        end

        render
      end
    end
  end

  def show
    @services = @protocol.organization.inclusive_descendant_services(:per_participant)
    @page     = 1

    gon.push({ protocol_id: @protocol.id })
  end

  private

  def find_protocol
    @protocol = Protocol.find_by_sparc_id(params[:id])
  end
end
