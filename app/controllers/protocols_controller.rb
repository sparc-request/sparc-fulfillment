class ProtocolsController < ApplicationController

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
    @protocol = Protocol.find_by_sparc_id(params[:id])
    @services = Service.per_patient
    @page = 1

    gon.push({ protocol_id: @protocol.id })
  end
end
