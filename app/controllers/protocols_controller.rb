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
    @protocol = Protocol.find_by(sparc_id: params[:id])
    @services = Service.all
    @page = 1
    respond_with [@protocol]
  end
end
