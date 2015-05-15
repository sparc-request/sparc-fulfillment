class ProtocolsController < ApplicationController

  respond_to :json, :html

  def index
    respond_to do |format|
      format.html { render }
      format.json do
        if params[:status].present? && params[:status] != 'All'
          @protocols = Protocol.where(status: params[:status])
        else
          @protocols = Protocol.all
        end

        render
      end
    end
  end

  def show
    @protocol = Protocol.find_by_sparc_id(params[:id])
    @services = Service.per_participant_visits
    @page = 1

    gon.push({ protocol_id: @protocol.id })
  end
end
